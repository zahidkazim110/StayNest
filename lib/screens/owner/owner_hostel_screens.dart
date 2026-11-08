import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../models/owner_hostel.dart';

class OwnerHostelsScreen extends StatefulWidget {
  const OwnerHostelsScreen({super.key});
  @override
  State<OwnerHostelsScreen> createState() => _OwnerHostelsScreenState();
}

class _OwnerHostelsScreenState extends State<OwnerHostelsScreen> {
  List<OwnerHostel> _hostels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await OwnerHostelStorage.getHostels();
    if (!mounted) return;
    setState(() { _hostels = items; _loading = false; });
  }

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => const AddHostelScreen()));
    if (saved == true) _load();
  }

  Future<void> _edit(OwnerHostel hostel) async {
    final saved = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => AddHostelScreen(existing: hostel)));
    if (saved == true) _load();
  }

  Future<void> _delete(OwnerHostel hostel) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) =>
      AlertDialog(
        title: const Text('Delete hostel?'),
        content: Text('Remove "${hostel.name}" and all its room records from this device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete')),
        ],
      ));
    if (confirmed == true) {
      await OwnerHostelStorage.deleteHostel(hostel.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('My Hostels')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add, backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_home_work_rounded), label: const Text('Add hostel')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _hostels.isEmpty ? _EmptyOwnerState(
          icon: Icons.apartment_rounded, title: 'No hostel listings yet',
          message: 'Create your first listing. Add its address, Google Maps location, facilities and rooms.',
          actionLabel: 'Create first listing', onAction: _add)
      : RefreshIndicator(
          onRefresh: _load,
          child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
            children: [
              Text('${_hostels.length} listing${_hostels.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ..._hostels.map((hostel) => Container(
                margin: const EdgeInsets.only(bottom: 13),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(19), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.apartment_rounded, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(hostel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text('${hostel.city} • ${hostel.address}', maxLines: 2,
                        overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _edit(hostel);
                        if (value == 'delete') _delete(hostel);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit listing')),
                        PopupMenuItem(value: 'delete', child: Text('Delete listing')),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    _MiniInfo(icon: Icons.meeting_room_outlined, label: '${hostel.rooms.length} rooms'),
                    const SizedBox(width: 15),
                    _MiniInfo(icon: Icons.bed_outlined,
                      label: '${hostel.rooms.fold<int>(0, (sum, room) => sum + room.availableBeds)} beds free'),
                    const Spacer(),
                    Text('${hostel.facilities.length} facilities',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ManageRoomsScreen(hostel: hostel)));
                      _load();
                    },
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Manage rooms and availability'),
                  )),
                ]),
              )),
            ],
          ),
        ),
  );
}

class AddHostelScreen extends StatefulWidget {
  final OwnerHostel? existing;
  const AddHostelScreen({super.key, this.existing});
  @override
  State<AddHostelScreen> createState() => _AddHostelScreenState();
}

class _AddHostelScreenState extends State<AddHostelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _maps = TextEditingController();
  String _city = 'Islamabad';
  double? _lat;
  double? _lng;
  bool _gettingLocation = false;
  bool _saving = false;
  final Set<String> _facilities = {};
  static const _facilityOptions = [
    'Wi-Fi', 'Mess', 'Laundry', 'Air conditioning', 'Heating',
    'Generator backup', 'CCTV security', 'Parking', 'Study room',
    'Attached bathroom', 'Cleaning', 'RO water',
  ];

  @override
  void initState() {
    super.initState();
    final hostel = widget.existing;
    if (hostel != null) {
      _name.text = hostel.name;
      _address.text = hostel.address;
      _description.text = hostel.description;
      _phone.text = hostel.contactPhone;
      _maps.text = hostel.googleMapsUrl;
      _city = hostel.city;
      _lat = hostel.latitude;
      _lng = hostel.longitude;
      _facilities.addAll(hostel.facilities);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _address.dispose(); _description.dispose();
    _phone.dispose(); _maps.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Turn on location services and try again.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required. You can paste a Google Maps link instead.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _maps.text = 'https://www.google.com/maps/search/?api=1&query=${_lat},${_lng}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your current map pin has been added.')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  void _readCoordinatesFromLink() {
    final match = RegExp(r'(-?\d{1,2}\.\d+)\s*[,/]\s*(-?\d{1,3}\.\d+)')
      .firstMatch(_maps.text) ??
      RegExp(r'!3d(-?\d{1,2}\.\d+)!4d(-?\d{1,3}\.\d+)')
          .firstMatch(_maps.text);
    if (match == null) {
      setState(() { _lat = null; _lng = null; });
      return;
    }
    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      setState(() { _lat = null; _lng = null; });
      return;
    }
    setState(() { _lat = lat; _lng = lng; });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final hostel = OwnerHostel(
        id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(), address: _address.text.trim(), city: _city,
        description: _description.text.trim(), contactPhone: _phone.text.trim(),
        googleMapsUrl: _maps.text.trim(), latitude: _lat, longitude: _lng,
        facilities: _facilities, rooms: widget.existing?.rooms ?? const [],
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );
      await OwnerHostelStorage.saveHostel(hostel);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hostel listing saved on this device.'), backgroundColor: AppColors.success));
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this listing. Please try again.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(widget.existing == null ? 'Add New Hostel' : 'Edit Hostel')),
    body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 32), children: [
      const _FormIntro(icon: Icons.add_business_rounded, title: 'List your property',
        subtitle: 'Give students the details they need to find a safe, comfortable place to stay.'),
      const SizedBox(height: 22),
      _FieldLabel('Hostel name *'),
      TextFormField(controller: _name, textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'e.g. Green View Boys Hostel'),
        validator: (v) => (v == null || v.trim().length < 3) ? 'Enter a hostel name' : null),
      const SizedBox(height: 16),
      _FieldLabel('City *'),
      DropdownButtonFormField<String>(
        initialValue: _city, decoration: const InputDecoration(),
        items: const ['Islamabad', 'Rawalpindi', 'Lahore', 'Karachi', 'Peshawar', 'Other']
          .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) { if (v != null) setState(() => _city = v); }),
      const SizedBox(height: 16),
      _FieldLabel('Full address *'),
      TextFormField(controller: _address, minLines: 2, maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Street, sector, nearby landmark'),
        validator: (v) => (v == null || v.trim().length < 6) ? 'Enter the complete address' : null),
      const SizedBox(height: 21),
      const _SectionHeading('Google Maps location', 'Pin your exact hostel entrance so students can navigate to it.'),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.location_on_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(child: Text('Add a precise map pin', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          ]),
          const SizedBox(height: 7),
          const Text('Use your phone GPS while standing at the hostel, or paste its Google Maps share link.',
            style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _gettingLocation ? null : _useCurrentLocation,
            icon: _gettingLocation
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location_rounded),
            label: Text(_gettingLocation ? 'Getting location...' : 'Use current GPS location')),
          const SizedBox(height: 10),
          TextFormField(controller: _maps, onChanged: (_) => _readCoordinatesFromLink(),
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(hintText: 'Paste Google Maps link or coordinates', prefixIcon: Icon(Icons.map_outlined)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Add a Google Maps link or use GPS';
              if (!v.contains('maps.google.') && !v.contains('goo.gl') && !RegExp(r'-?\d{1,2}\.\d+\s*[,/]\s*-?\d{1,3}\.\d+').hasMatch(v)) {
                return 'Paste a valid Google Maps link or coordinates';
              }
              return null;
            }),
          if (_lat != null && _lng != null) ...[
            const SizedBox(height: 9),
            Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 17),
              const SizedBox(width: 6),
              Expanded(child: Text('Pin: ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600))),
              IconButton(tooltip: 'Copy coordinates', onPressed: () => Clipboard.setData(
                ClipboardData(text: '$_lat,$_lng')), icon: const Icon(Icons.copy_rounded, size: 17)),
            ]),
          ],
        ]),
      ),
      const SizedBox(height: 20),
      _FieldLabel('Contact phone *'),
      TextFormField(controller: _phone, keyboardType: TextInputType.phone,
        decoration: const InputDecoration(hintText: '+92 3XX XXXXXXX', prefixIcon: Icon(Icons.phone_outlined)),
        validator: (v) => (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) ? 'Enter a valid contact number' : null),
      const SizedBox(height: 16),
      _FieldLabel('About this hostel'),
      TextFormField(controller: _description, minLines: 3, maxLines: 5,
        decoration: const InputDecoration(hintText: 'Describe the environment, rules, nearby universities and what makes your hostel special...')),
      const SizedBox(height: 21),
      const _SectionHeading('Facilities and amenities', 'Select everything available at your property.'),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 7, children: _facilityOptions.map((item) =>
        FilterChip(label: Text(item), selected: _facilities.contains(item),
          selectedColor: AppColors.primaryLight,
          checkmarkColor: AppColors.primary,
          onSelected: (selected) => setState(() {
            selected ? _facilities.add(item) : _facilities.remove(item);
          }))).toList()),
      const SizedBox(height: 28),
      SizedBox(height: 54, child: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: _saving ? const CircularProgressIndicator(color: Colors.white)
          : Text(widget.existing == null ? 'Save hostel listing' : 'Update hostel listing'))),
      const SizedBox(height: 9),
      const Text('You can add room types, rent and bed availability after saving.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
    ])),
  );
}

class ManageRoomsScreen extends StatefulWidget {
  final OwnerHostel hostel;
  const ManageRoomsScreen({super.key, required this.hostel});
  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  late OwnerHostel _hostel;
  @override
  void initState() { super.initState(); _hostel = widget.hostel; _refresh(); }

  Future<void> _refresh() async {
    final all = await OwnerHostelStorage.getHostels();
    final match = all.where((h) => h.id == widget.hostel.id);
    if (mounted && match.isNotEmpty) setState(() => _hostel = match.first);
  }

  Future<void> _addRoom() async {
    final name = TextEditingController();
    final rent = TextEditingController();
    final capacity = TextEditingController(text: '2');
    final available = TextEditingController(text: '2');
    String type = 'Shared';
    final amenities = <String>{'Fan', 'Wi-Fi'};
    final result = await showDialog<bool>(context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
        title: const Text('Add room'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Room number / name', hintText: 'e.g. Room 101')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: type,
            decoration: const InputDecoration(labelText: 'Room type'),
            items: const ['Single', 'Double', 'Triple', 'Shared', 'Family']
              .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) { if (v != null) setDialog(() => type = v); }),
          const SizedBox(height: 10),
          TextField(controller: rent, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly rent per bed (PKR)')),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: capacity, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total beds'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: available, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Available beds'))),
          ]),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: Text('Room facilities',
            style: Theme.of(ctx).textTheme.labelLarge)),
          Wrap(spacing: 5, children: ['Fan', 'AC', 'Attached bath', 'Study table', 'Wardrobe', 'Wi-Fi']
            .map((v) => FilterChip(label: Text(v), selected: amenities.contains(v),
              onSelected: (yes) => setDialog(() { yes ? amenities.add(v) : amenities.remove(v); }))).toList()),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final total = int.tryParse(capacity.text) ?? 0;
            final free = int.tryParse(available.text) ?? -1;
            final price = int.tryParse(rent.text) ?? 0;
            if (name.text.trim().isEmpty || total < 1 || free < 0 || free > total || price < 1) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Check room name, rent and bed counts.')));
              return;
            }
            Navigator.pop(ctx, true);
          }, child: const Text('Add room')),
        ],
      )));
    if (result == true) {
      final room = HostelRoom(id: DateTime.now().microsecondsSinceEpoch.toString(),
        roomName: name.text.trim(), roomType: type,
        monthlyRent: int.parse(rent.text), capacity: int.parse(capacity.text),
        availableBeds: int.parse(available.text), facilities: amenities);
      await OwnerHostelStorage.saveRoom(_hostel.id, room);
      await _refresh();
    }
    name.dispose(); rent.dispose(); capacity.dispose(); available.dispose();
  }

  Future<void> _changeAvailability(HostelRoom room) async {
    final controller = TextEditingController(text: room.availableBeds.toString());
    final value = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Update ${room.roomName}'),
      content: TextField(controller: controller, autofocus: true, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Available beds (0–${room.capacity})')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final parsed = int.tryParse(controller.text);
          if (parsed == null || parsed < 0 || parsed > room.capacity) return;
          Navigator.pop(ctx, parsed);
        }, child: const Text('Save')),
      ],
    ));
    controller.dispose();
    if (value != null) {
      await OwnerHostelStorage.saveRoom(_hostel.id, room.copyWith(availableBeds: value));
      _refresh();
    }
  }

  Future<void> _deleteRoom(HostelRoom room) async {
    await OwnerHostelStorage.deleteRoom(_hostel.id, room.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final total = _hostel.rooms.fold<int>(0, (sum, r) => sum + r.capacity);
    final free = _hostel.rooms.fold<int>(0, (sum, r) => sum + r.availableBeds);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Rooms')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRoom, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded), label: const Text('Add room')),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 100), children: [
        Text(_hostel.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('${_hostel.city} • ${_hostel.address}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _RoomSummary(value: _hostel.rooms.length.toString(), label: 'Rooms')),
          const SizedBox(width: 9),
          Expanded(child: _RoomSummary(value: total.toString(), label: 'Total beds')),
          const SizedBox(width: 9),
          Expanded(child: _RoomSummary(value: free.toString(), label: 'Available')),
        ]),
        const SizedBox(height: 20),
        if (_hostel.rooms.isEmpty)
          _EmptyOwnerState(icon: Icons.bedroom_parent_outlined, title: 'No rooms added',
            message: 'Add room numbers, room types, monthly rent and available beds to make your listing useful.',
            actionLabel: 'Add first room', onAction: _addRoom)
        else ..._hostel.rooms.map((room) => Container(
          margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
                color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.meeting_room_rounded, color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.roomName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(room.roomType, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              PopupMenuButton<String>(onSelected: (v) {
                if (v == 'availability') _changeAvailability(room);
                if (v == 'delete') _deleteRoom(room);
              }, itemBuilder: (_) => const [
                PopupMenuItem(value: 'availability', child: Text('Update availability')),
                PopupMenuItem(value: 'delete', child: Text('Delete room')),
              ]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Text('PKR ${room.monthlyRent.toString()} / bed / month',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const Spacer(),
              Text('${room.availableBeds} of ${room.capacity} beds free',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: room.capacity == 0 ? 0 : (room.capacity - room.availableBeds) / room.capacity,
                minHeight: 7, color: AppColors.primary, backgroundColor: AppColors.primaryLight)),
            if (room.facilities.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(room.facilities.join(' • '), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ]),
        )),
      ]),
    );
  }
}

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background, appBar: AppBar(title: const Text('Booking Requests')),
    body: const _EmptyOwnerState(
      icon: Icons.event_note_rounded, title: 'No booking requests yet',
      message: 'Student requests will appear here when StayNest is connected to its booking backend. You will be able to review, approve or decline each request.',
    ),
  );
}

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});
  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _name.dispose(); _phone.dispose(); _email.dispose(); super.dispose(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name.text = prefs.getString('staynest_owner_name') ?? '';
    _phone.text = prefs.getString('staynest_owner_phone') ?? '';
    _email.text = prefs.getString('staynest_owner_email') ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your name and a valid phone number.')));
      return;
    }
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staynest_owner_name', _name.text.trim());
    await prefs.setString('staynest_owner_phone', _phone.text.trim());
    await prefs.setString('staynest_owner_email', _email.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Owner profile saved on this device.'), backgroundColor: AppColors.success));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background, appBar: AppBar(title: const Text('Owner Profile')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : ListView(padding: const EdgeInsets.all(20), children: [
        const _FormIntro(icon: Icons.manage_accounts_rounded, title: 'Your owner account',
          subtitle: 'Keep your contact information up to date so students can reach you.'),
        const SizedBox(height: 24),
        const _FieldLabel('Full name'),
        TextField(controller: _name, textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name', prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 16),
        const _FieldLabel('Phone number'),
        TextField(controller: _phone, keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+92 3XX XXXXXXX', prefixIcon: Icon(Icons.phone_outlined))),
        const SizedBox(height: 16),
        const _FieldLabel('Email address'),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'name@example.com', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 25),
        SizedBox(height: 52, child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save profile'))),
        const SizedBox(height: 18),
        const Text('Profile details are currently stored locally on this device. Cloud account sync will be enabled with the StayNest backend.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.textMuted)),
      ]),
  );
}

class _FormIntro extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _FormIntro({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(
      color: AppColors.primaryLight, borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: AppColors.primary, size: 27)),
    const SizedBox(width: 13),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondary)),
    ])),
  ]);
}

class _SectionHeading extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeading(this.title, this.subtitle);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    const SizedBox(height: 4),
    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  );
}

class _MiniInfo extends StatelessWidget {
  final IconData icon; final String label;
  const _MiniInfo({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 15, color: AppColors.primary), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}

class _RoomSummary extends StatelessWidget {
  final String value, label;
  const _RoomSummary({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]));
}

class _EmptyOwnerState extends StatelessWidget {
  final IconData icon; final String title, message;
  final String? actionLabel; final VoidCallback? onAction;
  const _EmptyOwnerState({required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(
        color: AppColors.primaryLight, shape: BoxShape.circle), child: Icon(icon, size: 35, color: AppColors.primary)),
      const SizedBox(height: 17),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
      if (actionLabel != null && onAction != null) ...[
        const SizedBox(height: 18), ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ]),
  ));
}
