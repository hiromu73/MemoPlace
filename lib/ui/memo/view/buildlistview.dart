import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BuildListView extends HookConsumerWidget {
  const BuildListView(this.query, BuildContext context, {super.key});
  final QuerySnapshot query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = 0;
    Color baseColor = Colors.orange.shade100;
    User? user = FirebaseAuth.instance.currentUser;
    return FutureBuilder(
      future: checkPermission(query, context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ListView(
          padding:
              const EdgeInsets.only(top: 60, right: 5, left: 5, bottom: 110),
          children: query.docs.map((DocumentSnapshot document) {
            final int staggerPosition = index++;
            return Slidable(
              key: Key(document.id),
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (BuildContext context) async {
                      try {
                        String docId = document.id;
                        await FirebaseFirestore.instance
                            .collection('post')
                            .doc(user!.uid)
                            .collection('documents')
                            .doc(docId)
                            .delete();
                      } catch (e) {
                        if (context.mounted) {
                          context.pop();
                        }
                      }
                    },
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: AppLocalizations.of(context)!.delete,
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      try {
                        context.push('/editpage', extra: document);
                      } catch (e) {
                        if (context.mounted) {
                          context.pop();
                        }
                      }
                    },
                    backgroundColor: const Color(0xFF21B7CA),
                    foregroundColor: Colors.white,
                    icon: Icons.create,
                    label: AppLocalizations.of(context)!.edit,
                  ),
                ],
              ),
              child: AnimationConfiguration.staggeredList(
                position: staggerPosition,
                duration: const Duration(milliseconds: 1000),
                child: FlipAnimation(
                  child: ScaleAnimation(
                    child: Column(children: [
                      document['alert'] == true
                          ? Card(
                              margin: const EdgeInsets.all(10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(3, 3),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(-3, -3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        document['text'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: CupertinoSwitch(
                                          activeColor: Colors.amber,
                                          trackColor: Colors.grey,
                                          value: document['alert'],
                                          onChanged: (value) async {
                                            String docId = document.id;
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('post')
                                                  .doc(user!.uid)
                                                  .collection('documents')
                                                  .doc(docId)
                                                  .update({
                                                'alert': value,
                                              });
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          }),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          document['checkName'] != null
                                              ? Text(
                                                  "場所\n${document['checkName']}"
                                                      .toString())
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.end,
                                    //   children: [
                                    //     IconButton(
                                    //         color: Colors.grey,
                                    //         icon: const Icon(Icons.delete),
                                    //         onPressed: () async {
                                    //           showDialog(
                                    //             context: context,
                                    //             builder: (BuildContext context) {
                                    //               return AlertDialog(
                                    //                 content:
                                    //                     const Text(deleteMemo),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                       // isDefaultAction: true,
                                    //                       onPressed: () async {
                                    //                         try {
                                    //                           String docId =
                                    //                               document.id;
                                    //                           await FirebaseFirestore
                                    //                               .instance
                                    //                               .collection(
                                    //                                   'post')
                                    //                               .doc(userId)
                                    //                               .collection(
                                    //                                   'documents')
                                    //                               .doc(docId)
                                    //                               .delete();
                                    //                           if (context
                                    //                               .mounted) {
                                    //                             Navigator.pop(
                                    //                                 context);
                                    //                           }
                                    //                         } catch (e) {
                                    //                           if (context
                                    //                               .mounted) {
                                    //                             Navigator.pop(
                                    //                                 context);
                                    //                           }
                                    //                         }
                                    //                       },
                                    //                       child: const Text(ok)),
                                    //                   TextButton(
                                    //                       child: const Text(no),
                                    //                       onPressed: () {
                                    //                         Navigator.pop(
                                    //                             context);
                                    //                       }),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         }),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            )
                          : Card(
                              margin: const EdgeInsets.all(10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(-3, -3),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.6),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        document['text'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: CupertinoSwitch(
                                          activeColor: Colors.amber,
                                          trackColor: Colors.grey,
                                          value: document['alert'],
                                          onChanged: (value) async {
                                            String docId = document.id;

                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('post')
                                                  .doc(user!.uid)
                                                  .collection('documents')
                                                  .doc(docId)
                                                  .update({
                                                'alert': value,
                                              });
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          }),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          document['checkName'] != null
                                              ? Text(
                                                  "場所\n${document['checkName']}"
                                                      .toString())
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.end,
                                    //   children: [
                                    //     IconButton(
                                    //       color: Colors.grey,
                                    //       icon: const Icon(Icons.delete),
                                    //       onPressed: () async {
                                    //         showDialog(
                                    //             context: context,
                                    //             builder: (BuildContext context) {
                                    //               return AlertDialog(
                                    //                 title: const Text(deleteMemo),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                       onPressed: () async {
                                    //                         try {
                                    //                           String docId =
                                    //                               document.id;
                                    //                           await FirebaseFirestore
                                    //                               .instance
                                    //                               .collection(
                                    //                                   'post')
                                    //                               .doc(userId)
                                    //                               .collection(
                                    //                                   'documents')
                                    //                               .doc(docId)
                                    //                               .delete();
                                    //                           if (context
                                    //                               .mounted) {
                                    //                             Navigator.pop(
                                    //                                 context);
                                    //                           }
                                    //                         } catch (e) {
                                    //                           if (context
                                    //                               .mounted) {
                                    //                             Navigator.pop(
                                    //                                 context);
                                    //                           }
                                    //                         }
                                    //                       },
                                    //                       child: const Text(ok)),
                                    //                   TextButton(
                                    //                       child: const Text(no),
                                    //                       onPressed: () {
                                    //                         Navigator.pop(
                                    //                             context);
                                    //                       }),
                                    //                 ],
                                    //               );
                                    //             });
                                    //       },
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 10)
                    ]),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// MemoListのアラームが全てOFFになっているかどうか確認
Future<void> checkPermission(
    QuerySnapshot<Object?> query, BuildContext context) async {
  final permission = await Geolocator.checkPermission();
  if ((permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) &&
      context.mounted &&
      query.docs.isNotEmpty) {
    bool hasActiveAlerts = query.docs.any((DocumentSnapshot document) {
      return document['alert'] == true;
    });

    if (!hasActiveAlerts) {
      final no = AppLocalizations.of(context)!.no;
      final setting = AppLocalizations.of(context)!.setting;
      final location_check = AppLocalizations.of(context)!.location_check;
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(location_check),
            actions: <Widget>[
              TextButton(
                child: Text(setting),
                onPressed: () {
                  openAppSettings();
                },
              ),
              TextButton(
                child: Text(no),
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
}
