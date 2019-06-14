import 'dart:html';
import 'dart:convert';
import 'package:e_wallet/src/item.dart';


Storage ls = window.localStorage;

addItemToStorage(Map<String, dynamic> item){
  var items;
  // check if empty
  if (ls['items'] == null){
    items = [];
    // push new item
    items.add(item);

    // set ls to items
    ls['items'] = jsonEncode(items);
  } else {
    // get items from ls
    List<dynamic> items = jsonDecode(ls['items']);
    // add new item
    items.add(item);
    // update ls
    ls['items'] = jsonEncode(items);
  }
}

// get items from storage
getItemsFromStorage(){
  var items;
  List<Item> itemsList = [];

  if(ls["items"] == null){
    items = [];
  } else {
    items = jsonDecode(ls['items']);
    // get Item object from json
    for (var item in items){
      item = Item.fromJson(item);
      itemsList.add(item);
    }
  }
  return itemsList;
}

// update item in storage
void updateItemInStorage(Item updatedItem){
  var items = jsonDecode(ls['items']);
  var itemToUpdate = updatedItem.toJson();
  int index;

  for (var item in items){
    if (item["id"] == itemToUpdate["id"]){
      // get index of founded item
      index = items.indexOf(item);
      break;
    }
  }
  // update items
  items[index] = itemToUpdate;
  // update ls
  ls['items'] = jsonEncode(items);
}

// remove item from storage
void removeItemFromStorage(int id){
  List items = jsonDecode(ls['items']);

  items.removeWhere( (item) =>
      item["id"] == id);
  // update ls
  ls['items'] = jsonEncode(items);
}

// clear all storage
void clearAllStorage(){
  ls.remove('items');
  ls.remove('baseCurrency');
}

// add base currency to storage
void addBaseCurrencyToStorage(String currency){
  ls['baseCurrency'] = currency;
}

String getBaseCurrencyFromStorage(){
  String currency;
  if (ls['baseCurrency'] == null){
    // if empty set it to GBP as default
   ls['baseCurrency'] = 'GBP';
  } else {
    currency = ls['baseCurrency'];
  }
   return currency;
}