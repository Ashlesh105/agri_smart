import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  _TestHistoryScreenState createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final box = Hive.box('hive_boxes');

    if (isOnline) {
      try {
        final snapshot =
            await FirebaseFirestore.instance.collection('soilData').get();

        await box.clear();
        for (var doc in snapshot.docs) {
          box.add({'id': doc.id, ...doc.data()});
        }

        return snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      } catch (e) {
        return _getHiveData(box);
      }
    } else {
      return _getHiveData(box);
    }
  }

  List<Map<String, dynamic>> _getHiveData(Box box) {
    List<Map<String, dynamic>> result = [];
    for (var value in box.values) {
      if (value is Map<String, dynamic>) {
        result.add(value);
      }
    }
    return result;
  }

  void showDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Test Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildDetailWidgets(data),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildDetailWidgets(Map<String, dynamic> data) {
    List<Widget> widgets = [];

    data.forEach((key, value) {
      widgets.add(Text(
        '$key:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ));

      if (value is Map) {
        value.forEach((nestedKey, nestedValue) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('$nestedKey: $nestedValue'),
          ));
        });
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(value.toString()),
        ));
      }

      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test History')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No test history found.'));
            }

            final dataList = snapshot.data!;

            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final test = dataList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: ListTile(
                    title: Text('Test on ${test['timestamp']}'),
                    onTap: () => showDetails(test),
                    trailing: IconButton(
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete this test?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Yes'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance.collection('soilData').doc(test['id']).delete();
                            await Hive.box('hive_boxes').deleteAt(index);
                            setState(() {});
                          }
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        )),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
