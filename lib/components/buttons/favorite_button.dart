import 'package:flutter/material.dart';

import '../../models/hostel.dart';
import '../../models/hostel_activity_storage.dart';

class FavoriteButton extends StatefulWidget {
  final Hostel hostel;
  final double size;

  const FavoriteButton({
    super.key,
    required this.hostel,
    this.size = 23,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await HostelActivityStorage.isFavorite(widget.hostel);

    if (!mounted) return;

    setState(() {
      _isFavorite = status;
      _loading = false;
    });
  }

  Future<void> _toggle() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await HostelActivityStorage.toggleFavorite(widget.hostel);

      if (!mounted) return;

      setState(() {
        _isFavorite = !_isFavorite;
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'Added to Favorites'
                : 'Removed from Favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        onPressed: _toggle,
        tooltip: _isFavorite ? 'Remove Favorite' : 'Add Favorite',
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.black54,
          size: widget.size,
        ),
      ),
    );
  }
}
