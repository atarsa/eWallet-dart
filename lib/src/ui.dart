import 'dart:html';
import 'package:e_wallet/src/item.dart';

// define UI Selectors
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

// get UI Selectors
Map<String, String> getUISelectors(){
  return _UISelectors;
}

// get user input from item form
List getItemInput(){
  String currency = (querySelector(_UISelectors["itemCurrencyInput"]) as
  InputElement).value;
  
  String amount = (querySelector(_UISelectors["itemAmountInput"])
  as InputElement).value;

  return [currency, amount];
}

// add new item to existing list (UI)
void addListItemUI(Item listItem, Wallet wallet){
  // TODO: get base currency and exchange money
  String baseCurrency = wallet.baseCurrency;
  var convertedAmount;
  // Create list element
  var li = LIElement();
  // add class and data attribute
  li.className = 'collection-item';
  li.setAttribute('data-id', listItem.id.toString());

  // add html
  li.innerHtml = '''
        <a href="#" class="delete">
          <i class="delete-item fas fa-trash-alt"></i>
        </a>
        <a href="#" class="update">
          <i class="edit-item fas fa-edit"></i>
        </a>
        
        <span class="amount">${listItem.amount}</span>
        <span class="currency">${listItem.currency}</span>
       
        <span class="secondary-content">
          <span class="converted-amount">${convertedAmount}</span>
          <span class="base-currency">${baseCurrency}</span>
        </span>
  ''';
  // Insert element
  querySelector(_UISelectors["itemsList"]).insertAdjacentElement('beforeend',
      li);

  // TODO: updateTotalMoney();
  // check if items list previously empty
  // TODO: checkForItems();
}

void updateListItemUI(Item item, Wallet wallet){
  // TODO: get base currency and exchange money
  String baseCurrency = wallet.baseCurrency;
  var convertedAmount;

  (querySelector("[data-id='${item.id}']") as HtmlElement).innerHtml = '''
    <a href="#" class="delete">
        <i class="delete-item fas fa-trash-alt"></i>
      </a>
      <a href="#" class="update">
        <i class="edit-item fas fa-edit"></i>
      </a>
      <span class="amount">${item.amount}</span>
      <span class="currency">${item.currency}</span>
      
      <span class="secondary-content">
        <span class="converted-amount">${convertedAmount}</span>
        <span class="base-currency">${baseCurrency}</span>
      </span>
   ''';
  // TODO: update total money
  // updateTotalMoney();
}
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
// clear user input
void clearUserInput(){
  (querySelector(_UISelectors["itemCurrencyInput"]) as InputElement).value = '';
  (querySelector(_UISelectors["itemAmountInput"]) as InputElement).value = '';
}