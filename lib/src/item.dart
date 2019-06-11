class Item {
  int id;
  String currency;
  double amount;

  // item constructor
  Item(this.id, this.currency, this.amount);
  @override
  String toString() => '$id $currency $amount';

}

class Wallet {
  List<Item> _itemsList = [];
  String _baseCurrency = 'GBP';

  // Constructor
  Wallet(this._itemsList, this._baseCurrency);

  // methods
  // getters and setters
  List<Item> get itemsList{
    return _itemsList;
  }

  String get baseCurrency{
    return _baseCurrency;
  }
  set baseCurrency(String currency){
    this._baseCurrency = currency;
  }

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
    // TODO: add to local storage
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

  // TODO: update item

// TODO: get data item by id


// TODO: clear all data items

}

Item _currentItem;

//var _baseCurrency=  'GBP'; // init with GBP as default; TODO: get base
////currency from local storage on load
Map<String, double> _exchangeRates = {};

// Available currencies
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

// Public methods
Map<String,String> getCurrencyList(){
  return _currenciesList;
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

// TODO: clear all data items


// TODO: set current item
// TODO: get current item


// TODO: fetch currencies rates
// TODO: get exchange rates
// TODO:  set exchange rate
// TODO: exchange money