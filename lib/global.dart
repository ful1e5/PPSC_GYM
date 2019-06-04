class Global {
  // Data Id
  String clientId = 'default';
  String moneyId = 'default';

  // Setting Data
  void setMoneyId(String id) => {moneyId=id};
  void setClientId(String id) => {clientId=id};

  String getclientId(){
    return clientId;
  }
}