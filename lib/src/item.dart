import 'dart:html';
import 'dart:convert';
import 'package:e_wallet/src/storage.dart';

class Item {
  int id;
  String currency;
  double amount;

  // item constructor
  Item(this.id, this.currency, this.amount);
  @override
  String toString() => '$id $currency $amount';

  // convert item to json
  Map<String, dynamic> toJson() => {
    'id': id,
    'currency': currency,
    'amount': amount
  };
  // get Item object from Json
  Item.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        currency = json['currency'],
        amount = json['amount'];
}

class Wallet {
  List<Item> _itemsList = [];
  String _baseCurrency = 'GBP';
  Item _currentItem;
  // Constructor
  Wallet(this._itemsList, this._baseCurrency);

  // getters and setters
  // items list
  List<Item> get itemsList{
    return _itemsList;
  }
  set itemsList(List<Item> itemsList){
    _itemsList = itemsList;
  }
  // base currency
  String get baseCurrency{
    return _baseCurrency;
  }
  set baseCurrency(String currency) {
    this._baseCurrency = currency;
  }
  // current element
  Item get currentItem{
    return _currentItem;
  }
  setCurrentItem(Item item){
    _currentItem = item;
  }

  // class methods
  //  add item to items array
  Item addItem(String currency, double amount){
    int id;
    // create id
    if (_itemsList.isNotEmpty){
      id = _itemsList[_itemsList.length-1].id;
      id += 1;
    } else {
      id = 0;
    }
    // create new Item object
    Item newItem = Item(id, currency, amount);
    // add to array
    _itemsList.add(newItem);
    // add to local storage
    addItemToStorage(newItem.toJson());

    // return new item
    return newItem;
  }

  //  delete item from items array
  void deleteItem(int id){
    // get all ids
    List ids = _itemsList.map((item) => item.id).toList();
    // get the index of id
    final index = ids.indexOf(id);
    // remove item from list
    _itemsList.removeAt(index);
   }

  // update item
  Item updateItem(String currency, double amount) {
    Item found;

    for (var item in _itemsList) {
      if (item.id == _currentItem.id) {
        item.currency = currency;
        item.amount = amount;
        found = item;
      }
    }
    return found;
  }
    // get data item by id
    Item getItemById(int id) {
      Item found;
      // loop trough items
      _itemsList.forEach((item) =>
      {
        if (item.id == id){
          found = item
        }
      });
      return found;
    }

  // clear all data items
  clearDataItems(){
    _itemsList = [];
  }
}
// Initialise empty object for exchange rates
Map<String, dynamic> _exchangeRates = {};

// Available currencies with full names  country code
/* list compatible with https://exchangeratesapi.io/
and foreign exchange rates published by
the European Central Bank
https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html */
Map<String, String> _currenciesList = {'EUR': 'Euro',
'USD': 'US dollar',
'JPY': 'Japanese yen',
'BGN': 'Bulgarian lev',
'CZK': 'Czech koruna',
'DKK': 'Danish krone',
'GBP': 	'Pound sterling',
'HUF' :	'Hungarian forint',
'PLN' :	'Polish zloty',
'RON' :	'Romanian leu',
'SEK' :	'Swedish krona',
'CHF' :	'Swiss franc',
'ISK' :	'Icelandic krona',
'NOK' :	'Norwegian krone',
'HRK' :	'Croatian kuna',
'RUB' :	'Russian rouble',
'TRY' :	'Turkish lira',
'AUD' :	'Australian dollar',
'BRL': 	'Brazilian real',
'CAD': 	'Canadian dollar',
'CNY' :  'Chinese yuan renminbi',
'HKD'  : 'Hong Kong dollar',
'IDR'  : 'Indonesian rupiah',
'ILS' :	'Israeli shekel',
'INR' :	'Indian rupee',
'KRW' :'South Korean won',
'MXN' :	'Mexican peso',
'MYR' :	'Malaysian ringgit',
'NZD' :	'New Zealand dollar',
'PHP' :	'Philippine peso',
'SGD' :	'Singapore dollar',
'THB' :	'Thai baht',
'ZAR': 	'South African rand'};

// Available currencies with country code
Map<String, String> _currencyCountryList = {'EUR': 'eu',
  'USD': 'us',
  'JPY': 'jp',
  'BGN': 'bg',
  'CZK': 'cz',
  'DKK': 'dk',
  'GBP': 'gb',
  'HUF' :	'hu',
  'PLN' :	'pl',
  'RON' :	'ro',
  'SEK' :	'se',
  'CHF' :	'ch',
  'ISK' :	'is',
  'NOK' :	'no',
  'HRK' :	'hr',
  'RUB' :	'ru',
  'TRY' :	'tr',
  'AUD' :	'au',
  'BRL': 	'br',
  'CAD': 	'ca',
  'CNY' :  'cn',
  'HKD'  : 'hk',
  'IDR'  : 'id',
  'ILS' :	'il',
  'INR' :	'in',
  'KRW' : 'kr',
  'MXN' :	'mx',
  'MYR' :	'my',
  'NZD' :	'nz',
  'PHP' :	'ph',
  'SGD' :	'sg',
  'THB' :	'th',
  'ZAR': 	'za'
};


// Public methods
Map<String,String> getCurrencyList(){
  return _currenciesList;
}

Map<String, String> getCountryCodes(){
  return _currencyCountryList;
}

String getCurrencyFullName(String currencyAbrr){
  // iterate through available currencies
  // to get full currency name
  String currencyFullName = '';
  _currenciesList.forEach((k,v) => {
    if (k == currencyAbrr){currencyFullName = v}
  });

  return currencyFullName;
}

// get exchange rates
Map<String,num> getExchangeRates(){
    return _exchangeRates;
  }

// set exchange rate
setExchangeRates(Map<String,num> rates){
  _exchangeRates = rates;
}

//  fetch currencies exchange rates
 void fetchCurrencyExchangeRates (String baseCurrency) async{
  try {
    String url = 'https://api.exchangeratesapi.io/latest?base=$baseCurrency';

    var exchangeRates = {};

    var dataString = await HttpRequest.getString(url);
    // convert string to Json
    var dataJson = jsonDecode(dataString);
    // get exchange rates
    exchangeRates = (dataJson["rates"] as Map).cast<String, num>();
    setExchangeRates(exchangeRates);
  } catch ( e) {
    // clear base currency value if null value
    (querySelector("#base-currency") as InputElement).value
    = "";
  }
}

String exchangeMoney(String currency, double amount){
  double money = 0;
  //var exchangeRates = Map.from(_exchangeRates);
  // get exchange rate for given currency
  for (var key in _exchangeRates.keys){
    if (key == currency){
      final value = _exchangeRates[currency];
      money = (amount / value);
    }
  }
  return money.toStringAsFixed(2);
}

