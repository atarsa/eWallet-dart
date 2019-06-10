import 'dart:html';
import 'package:e_wallet/src/item.dart';
// UI Selectors
final _UISelectors = {
  'itemCurrencyInput': '#item-currency',
  'baseCurrencyInput': '#base-currency',
  'currencyInput': '.currency-input',
  'itemAmountInput': '#item-amount',
  'itemsList': '#items-list',
  'listItems': '#items-list li',
  'currencyListItem': '.currency-list.item',
  'currencyListBase': '.currency-list.base',
  'currencyList': '.currency-list',
  'convertedAmount': '.converted-amount',
  // total
  'totalAmount': 'h4 .total-money',
  'totalCurrency': 'h4 .base-currency',
  // buttons
  'addBtn': '.add-btn',
  'updateBtn': '.update-btn',
  'backBtn': '.back-btn',
  'clearBtn': '.clear-btn'
};
// show list of available currencies on user input change
void showCurrencyList(Event e){
  Map<String, String> availableCurrency = getCurrencyList();
  final clickedElem = e.target as HtmlElement;

  UListElement currencyList;
  String currencyInput;

  // get classes of clicked element
  if(clickedElem.classes.contains('base')){
    // base currency input
    currencyList = querySelector(_UISelectors["currencyListBase"]);
    currencyInput = (querySelector(_UISelectors["baseCurrencyInput"]) as
    InputElement).value;
  } else {
    // item currency input
    currencyList = querySelector(_UISelectors["currencyListItem"]);
    currencyInput = (querySelector(_UISelectors["itemCurrencyInput"]) as
    InputElement).value;
  }
  // clear list on each key up
  currencyList.innerHtml = '';

  String ulHTML = '';
  // filter currency with user input
  for (MapEntry<String, String> currency in availableCurrency
      .entries ){
    if (currency.key.toLowerCase().contains(currencyInput.toLowerCase()) ||
    currency.value.toLowerCase().contains(currencyInput.toLowerCase())){
      ulHTML += '''<li class='collection-item'>${currency.key} <span class='small'>${currency.value} </span></li>''';
    }
  }
  // update currency list inner html
  currencyList.innerHtml = ulHTML;


}

getUISelectors(){
  return _UISelectors;
}