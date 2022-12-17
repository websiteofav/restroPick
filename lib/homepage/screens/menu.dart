import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restropick/db/repository.dart';
import 'package:restropick/homepage/model/menu_model.dart';
import 'package:restropick/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> categories = [];
  MenuModel? menuItems;
  Map<String, dynamic> isExpandedList = {};

  List<MenuIten> _selectedMenuItems = [];
  List<MenuIten> _previouslyOrderedMenuItems = [];
  MenuIten? mostBought;

  final LocalDBRepository _localDBRepository = LocalDBRepository();

  Future<List> _getData() async {
    final String response = await rootBundle.loadString('assets/menu.json');
    debugPrint(response.toString());

    var data = json.decode(response);
    menuItems = MenuModel.fromJson(data);

    if (!await _checkFirstTimeLoginAndCreateTable()) {
      _previouslyOrderedMenuItems = await _localDBRepository.getAllMenuItem();

      _previouslyOrderedMenuItems =
          _resetAvailability(_previouslyOrderedMenuItems);

      menuItems!.allItems!.insertAll(0, _previouslyOrderedMenuItems);
    }

    menuItems!.allItems!.map((e) {
      if (!categories.contains(e.category)) {
        if (e.category == 'Popular Items') {
          categories.insert(0, e.category.toString());
        } else {
          categories.add(e.category.toString());
        }
        isExpandedList[e.category.toString()] = false;
      }
    }).toList();

    return categories;
  }

  Future<bool> _checkFirstTimeLoginAndCreateTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('first_time');

    if (firstTime == null) {
      _localDBRepository.createMenuDB();
      prefs.setBool('first_time', false);
      return true;
    } else {
      return false;
    }
  }

  List<MenuIten> _resetAvailability(List<MenuIten> menuItemsChange) {
    menuItemsChange.map((e) {
      e.instock = e.instock == 1;
      MenuIten item =
          menuItems!.allItems!.firstWhere((element) => element.name == e.name);
      if (!item.instock) {
        e.instock = false;
      }
    }).toList();

    return menuItemsChange;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _floatingActionButton(),
        appBar: AppBar(
            // alignment: Alignment.bottomLeft,
            centerTitle: false,
            automaticallyImplyLeading: true,
            backgroundColor: cFF7961,
            titleSpacing: 15,
            title: const Text(
              'RestroPick',
              style: TextStyle(
                  color: coC54BE, fontSize: 22, fontWeight: FontWeight.bold),
            )),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: FutureBuilder<List>(
            future: _getData(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                // return Container();
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpansionPanelList(
                        dividerColor: cC3B9B9,
                        elevation: 9,
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            isExpandedList[snapshot.data![index].toString()] =
                                !isExpandedList[
                                    snapshot.data![index].toString()];
                          });
                        },
                        children: snapshot.data!.map<ExpansionPanel>((item) {
                          return ExpansionPanel(
                              canTapOnHeader: true,
                              isExpanded: isExpandedList[item] ?? true,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text(
                                    item,
                                    style: const TextStyle(
                                        color: black, fontSize: 25),
                                  ),
                                );
                              },
                              body: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: menuItems!.allItems!.length,
                                  itemBuilder: (ctx, index) {
                                    final menuItem =
                                        menuItems!.allItems![index];
                                    int quantity = 0;

                                    _selectedMenuItems.map((e) {
                                      if (e.name == menuItem.name) {
                                        quantity = e.quantity!.toInt();
                                      }
                                    }).toList();
                                    return menuItem.category == item
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  // height: 50,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            130,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                                child: RichText(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              text: TextSpan(
                                                                children: <
                                                                    TextSpan>[
                                                                  TextSpan(
                                                                    text: menuItem
                                                                        .name
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color:
                                                                            c55554D,
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  // if (!menuItem
                                                                  //     .instock)
                                                                  //   const TextSpan(
                                                                  //     text:
                                                                  //         '    Out of stock',
                                                                  //     style: TextStyle(
                                                                  //         // backgroundColor:
                                                                  //         //     black,
                                                                  //         color: black,
                                                                  //         fontSize: 14),
                                                                  //   ),
                                                                ],
                                                              ),
                                                            )
                                                                // Text(
                                                                //   menuItem.name
                                                                //       .toString(),
                                                                //   overflow:
                                                                //       TextOverflow
                                                                //           .visible,
                                                                // style: const TextStyle(
                                                                //     color:
                                                                //         c55554D,
                                                                //     fontSize:
                                                                //         20,
                                                                //     fontWeight:
                                                                //         FontWeight
                                                                //             .bold),
                                                                // ),
                                                                ),
                                                            if (index == 0 &&
                                                                menuItem.category ==
                                                                    'Popular Items')
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                            if (index == 0 &&
                                                                menuItem.category ==
                                                                    'Popular Items')
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                width: 100,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(2),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        cEB0EA5,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: const [
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        'Best seller',
                                                                        style: TextStyle(
                                                                            color:
                                                                                cffffff,
                                                                            fontSize:
                                                                                14),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                          '₹ ${menuItem.price.toString()}',
                                                          style:
                                                              const TextStyle(
                                                            color: c767272,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (quantity == 0 &&
                                                        menuItem.instock) {
                                                      setState(() {
                                                        MenuIten model = MenuIten(
                                                            category: menuItem
                                                                .category,
                                                            instock: menuItem
                                                                .instock,
                                                            name: menuItem.name,
                                                            price:
                                                                menuItem.price,
                                                            quantity: 1);
                                                        _selectedMenuItems
                                                            .add(model);
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        // color: textColor6,
                                                        color: menuItem.instock
                                                            ? cffffff
                                                            : cC3B9B9,
                                                        border: Border.all(
                                                            color: cD43F25_1)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        if (quantity > 0)
                                                          InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  int itemIndex =
                                                                      -1;
                                                                  _selectedMenuItems
                                                                      .map((e) {
                                                                    if (e.name ==
                                                                        menuItem
                                                                            .name) {
                                                                      itemIndex =
                                                                          _selectedMenuItems
                                                                              .indexOf(e);
                                                                    }
                                                                  }).toList();
                                                                  if (itemIndex >=
                                                                      0) {
                                                                    _selectedMenuItems[itemIndex].quantity ==
                                                                            1
                                                                        ? _selectedMenuItems.removeAt(
                                                                            itemIndex)
                                                                        : _selectedMenuItems[itemIndex]
                                                                            .quantity = _selectedMenuItems[itemIndex]
                                                                                .quantity! -
                                                                            1;
                                                                  }
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.remove,
                                                                color:
                                                                    cD43F25_1,
                                                                size: 16,
                                                              )),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 0),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 0),
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: !menuItem
                                                                          .instock
                                                                      ? cC3B9B9
                                                                      : quantity ==
                                                                              0
                                                                          ? cffffff
                                                                          : cD43F25_1),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              quantity == 0
                                                                  ? 'Add'
                                                                  : quantity
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  color: quantity ==
                                                                          0
                                                                      ? cD43F25_1
                                                                      : cffffff,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ),
                                                        if (quantity > 0)
                                                          InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  int itemIndex =
                                                                      -1;
                                                                  _selectedMenuItems
                                                                      .map((e) {
                                                                    if (e.name ==
                                                                        menuItem
                                                                            .name) {
                                                                      itemIndex =
                                                                          _selectedMenuItems
                                                                              .indexOf(e);
                                                                    }
                                                                  }).toList();
                                                                  if (itemIndex >=
                                                                      0) {
                                                                    _selectedMenuItems[
                                                                            itemIndex]
                                                                        .quantity = _selectedMenuItems[itemIndex]
                                                                            .quantity! +
                                                                        1;
                                                                  } else {
                                                                    MenuIten model = MenuIten(
                                                                        category:
                                                                            menuItem
                                                                                .category,
                                                                        instock:
                                                                            menuItem
                                                                                .instock,
                                                                        name: menuItem
                                                                            .name,
                                                                        price: menuItem
                                                                            .price,
                                                                        quantity:
                                                                            1);
                                                                    _selectedMenuItems
                                                                        .add(
                                                                            model);
                                                                  }
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.add,
                                                                color:
                                                                    cD43F25_1,
                                                                size: 16,
                                                              )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container();
                                  }));
                        }).toList(),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  alignment: Alignment.center,
                  child: const Text(
                    'Something went wrong',
                    style: TextStyle(
                        color: cff0000,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: cffffff,
                    strokeWidth: 5,
                  ),
                );
              }
            }),
          ),
        ));
  }

  Widget _floatingActionButton() {
    var totalAmount = 0.0;
    _selectedMenuItems.map(
      (e) {
        totalAmount = totalAmount + (e.quantity! * (e.price as num));
      },
    ).toList();
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
      ),
      margin: const EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (totalAmount > 0) {
            bool result =
                await _localDBRepository.insertToMenuDB(_selectedMenuItems);
            if (mounted) {
              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: c33cc33,
                    content: Text(
                      'Order Placed',
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );

                _selectedMenuItems = [];
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: cff0000,
                    content: Text(
                      'Order Could not be placed',
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            }
          }
        },
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(cD43F25_1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Place order',
                textAlign: TextAlign.center,
                style: TextStyle(color: cffffff, fontSize: 18),
              ),
            ),
            // Spacer(),
            const SizedBox(
              width: 10,
            ),
            if (totalAmount > 0)
              Flexible(
                child: Text(
                  '₹${totalAmount.toString()}',
                  style: const TextStyle(color: cffffff, fontSize: 18),
                  overflow: TextOverflow.fade,
                ),
              )
          ],
        ),
      ),
    );
  }
}
