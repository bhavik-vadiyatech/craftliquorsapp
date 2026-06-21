// enum WeightChargeConditions {greater_or_equal, less_or_equal, greater, less}

enum WeightChargeConditions {
  greaterOrEqual('greater_or_equal'),
  lessOrEqual('less_or_equal'),
  greater('greater'),
  less('less');

  final String name;

  const WeightChargeConditions(this.name);
}