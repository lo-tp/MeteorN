var secondaries=['s1'];
var arb='arb';
rs.initiate();
secondaries.forEach(function(address){
  print(address);
  rs.add(address);
});
rs.addArb(arb);
rs.conf();
