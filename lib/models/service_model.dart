class BarberServiceItem {
  final String id;
  final String barberInternalId;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String category;
  bool isActive;

  BarberServiceItem({
    required this.id,
    required this.barberInternalId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.category = 'Haircut',
    this.isActive = true,
  });
}
