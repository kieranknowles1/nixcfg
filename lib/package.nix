{ }:
{
  ifEnabled = condition: packages: if condition then packages else [];
}
