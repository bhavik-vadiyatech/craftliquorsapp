enum OrderType {
  delivery('delivery'),
  selfPickup('self_pickup');

  final String name;

  const OrderType(this.name);
}