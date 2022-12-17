class MenuItenFields {
  static const String name = "name";
  static const String price = "price";

  static const String instock = "instock";

  static const String category = "category";

  static const String quantity = "quantity";

  static final List<String> values = [name, instock, price, category, quantity];
}

class MenuModel {
  // List<MenuIten>? cat1;
  // List<MenuIten>? cat2;
  // List<MenuIten>? cat3;
  // List<MenuIten>? cat4;
  // List<MenuIten>? cat5;
  // List<MenuIten>? cat6;

  List<MenuIten>? allItems = [];

  MenuModel(
      {
      //   this.cat1,
      // this.cat2,
      // this.cat3,
      // this.cat4,
      // this.cat5,
      // this.cat6,
      this.allItems});

  MenuModel.fromJson(Map<String, dynamic> json) {
    if (json['cat1'] != null) {
      // cat1 = [];
      json['cat1'].forEach((v) {
        allItems!.add(MenuIten.fromJson(v, 'cat1'));
      });
    }
    if (json['cat2'] != null) {
      // cat2 = [];
      json['cat2'].forEach((v) {
        allItems!.add(MenuIten.fromJson(v, 'cat2'));
      });
    }
    if (json['cat3'] != null) {
      // cat3 = [];
      json['cat3'].forEach((v) {
        allItems!.add(MenuIten.fromJson(v, 'cat3'));
      });
    }
    if (json['cat4'] != null) {
      // cat4 = [];
      json['cat4'].forEach((v) {
        allItems!.add(MenuIten.fromJson(v, 'cat4'));
      });
    }
    if (json['cat5'] != null) {
      // cat5 = [];
      json['cat5'].forEach((v) {
        allItems!.add(MenuIten.fromJson(v, 'cat5'));
      });
    }
    if (json['cat6'] != null) {
      // cat6 = [];
      json['cat6'].forEach((v) {
        allItems!.add(MenuIten.fromJson(v, 'cat6'));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (allItems != null) {
      data['allItems'] = allItems!.map((v) => v.toJson()).toList();
    }
    // if (cat2 != null) {
    //   data['cat2'] = cat2!.map((v) => v.toJson()).toList();
    // }
    // if (cat3 != null) {
    //   data['cat3'] = cat3!.map((v) => v.toJson()).toList();
    // }
    // if (cat4 != null) {
    //   data['cat4'] = cat4!.map((v) => v.toJson()).toList();
    // }
    // if (cat5 != null) {
    //   data['cat5'] = cat5!.map((v) => v.toJson()).toList();
    // }
    // if (cat6 != null) {
    //   data['cat6'] = cat6!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class MenuIten {
  String? name;
  int? price;
  dynamic instock;
  String? category;
  int? quantity;

  MenuIten({this.name, this.price, this.instock, this.category, this.quantity});

  MenuIten.fromJson(Map<String, dynamic> json, String categoryName) {
    name = json[MenuItenFields.name] as String;
    price = json[MenuItenFields.price] as int;
    instock = json[MenuItenFields.instock];
    category = categoryName;
    quantity = json[MenuItenFields.quantity] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[MenuItenFields.name] = name;
    data[MenuItenFields.price] = price;
    data[MenuItenFields.instock] = instock;
    data[MenuItenFields.category] = category;
    data[MenuItenFields.quantity] = quantity;
    return data;
  }
}
