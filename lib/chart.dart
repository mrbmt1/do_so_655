import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:do_so_655/connectivity_utils.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final _formKey = GlobalKey<FormState>();
  List<int> numbers = List.generate(55, (index) => index + 1);
  Map<int, int?> frequency = {};
  double _scale = 1.0;
  int? startCode = 0;
  int? endCode = 0;
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  int _jackpot1_winner = 0;
  int _jackpot2_winner = 0;
  int _jackpot1_prize = 0;
  int _jackpot2_prize = 0;
  bool _viewColumnChart = true;
  bool _viewLineChart = true;
  bool _view55 = true;
  bool _winner = true;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    ConnectivityUtils.checkConnectivity(context);
  }

  int numOfDrawPeriods = 1;
  void getData(int start, int end) async {
    if (start != null && end != null) {
      int startCode = start;
      int endCode = end;
      if (start != null && end != null) {
        endCode = end;
      }
      numOfDrawPeriods = endCode - startCode + 1;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vietlott_655_results')
          .where('draw_period', isGreaterThanOrEqualTo: startCode)
          .where('draw_period', isLessThanOrEqualTo: endCode)
          .get();

      List<DocumentSnapshot> docs = snapshot.docs;
      numOfDrawPeriods = docs.length;

      // Tính toán tần suất của các số
      for (int i = 1; i <= 55; i++) {
        frequency[i] = 0;
      }

      docs.forEach((doc) {
        for (int i = 0; i <= 6; i++) {
          if (doc.data() != null &&
              (doc.data() as Map<String, dynamic>).containsKey('number_$i')) {
            int? number = doc.get('number_$i');
            if (number != null) {
              frequency[number] = (frequency[number] ?? 0) + 1;
            }
          }
        }

        if ((doc.data() as Map<String, dynamic>)
            .containsKey('special_number')) {
          int? specialNumber = doc.get('special_number');
          if (specialNumber != null) {
            frequency[specialNumber] = (frequency[specialNumber] ?? 0) + 1;
          }
        }
      });

      // Lấy thông tin giải thưởng từ cơ sở dữ liệu
      num jackpot1_winner = 0;
      num jackpot2_winner = 0;
      num jackpot1_prize = 0;
      num jackpot2_prize = 0;
      docs.forEach((doc) {
        if ((doc.data() as Map<String, dynamic>)
            .containsKey('jackpot1_winner')) {
          jackpot1_winner += doc.get('jackpot1_winner');
        }
        if ((doc.data() as Map<String, dynamic>)
            .containsKey('jackpot2_winner')) {
          jackpot2_winner += doc.get('jackpot2_winner');
        }
        if ((doc.data() as Map<String, dynamic>)
            .containsKey('jackpot1_prize')) {
          jackpot1_prize += doc.get('jackpot1_prize');
        }
        if ((doc.data() as Map<String, dynamic>)
            .containsKey('jackpot2_prize')) {
          jackpot2_prize += doc.get('jackpot2_prize');
        }
      });

      // Gán giá trị mới cho các biến instance
      setState(() {
        _jackpot1_winner = jackpot1_winner.toInt();
        _jackpot2_winner = jackpot2_winner.toInt();
        _jackpot1_prize = jackpot1_prize.toInt();
        _jackpot2_prize = jackpot2_prize.toInt();
      });
    }
  }

  List<charts.Series<ChartData, String>> _createSampleData() {
    List<ChartData> data = [];
    for (int i = 1; i <= 55; i++) {
      int count = frequency[i] ?? 0;
      data.add(ChartData(i.toString(), count));
    }

    // Sắp xếp dữ liệu theo thứ tự tăng dần hoặc giảm dần nếu đã được bấm vào icon button
    if (!_sortAscending) {
      data.sort((a, b) => b.count.compareTo(a.count));
    }

    return [
      charts.Series<ChartData, String>(
        id: 'frequency',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ChartData data, _) => data.number,
        measureFn: (ChartData data, _) => data.count,
        data: data,
      ),
    ];
  }

  List<charts.Series<LineChartData, int>> _createSampleLineChartData() {
    List<LineChartData> data = [];
    for (int i = 1; i <= 55; i++) {
      int count = frequency[i] ?? 0;
      data.add(LineChartData(i, count));
    }

    return [
      charts.Series<LineChartData, int>(
        id: 'frequency',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LineChartData data, _) => data.number,
        measureFn: (LineChartData data, _) => data.count,
        data: data,
      )
    ];
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (model.hasDatumSelection) {
      final selectedDatum = model.selectedDatum.first;
      final snackBar = SnackBar(
        content: Text(
          'Số ${selectedDatum.datum.number}: ${selectedDatum.datum.count} lần',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void sortFrequency() {
    List<MapEntry<int, int?>> sortedEntries = frequency.entries.toList()
      ..sort((a, b) => a.value!.compareTo(b.value!));

    if (!_sortAscending) {
      sortedEntries = sortedEntries.reversed.toList();
    }

    frequency = Map.fromEntries(sortedEntries);
    setState(() {});
  }

  void sortColumnChartAscending() {
    setState(() {
      _sortAscending = true;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dữ liệu đã được sắp xếp theo thứ tự từ 1 đến 55'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void sortColumnChartDescending() {
    setState(() {
      _sortAscending = false;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dữ liệu đã được sắp xếp theo thứ tự giảm dần'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Thống kê 6/55'),
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 22, 25, 179),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'column_chart':
                    setState(() {
                      _viewColumnChart = !_viewColumnChart;
                    });
                    break;
                  case 'line_chart':
                    setState(() {
                      _viewLineChart = !_viewLineChart;
                    });
                    break;
                  case 'frequency_list':
                    setState(() {
                      _view55 = !_view55;
                    });
                    break;
                  case 'winning_statistics':
                    setState(() {
                      _winner = !_winner;
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'column_chart',
                  child: Text('Hiển thị biểu đồ cột'),
                ),
                PopupMenuItem<String>(
                  value: 'line_chart',
                  child: Text('Hiển thị biểu đồ đường'),
                ),
                PopupMenuItem<String>(
                  value: 'frequency_list',
                  child: Text('Hiển thị danh sách tần suất'),
                ),
                PopupMenuItem<String>(
                  value: 'winning_statistics',
                  child: Text('Hiển thị thông số trúng thưởng'),
                ),
              ],
            )
          ],
        ),
        body: Container(
          child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 22, 25, 179),
                    Color.fromARGB(255, 172, 40, 16),
                  ],
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _startController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Kỳ bắt đầu',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Vui lòng nhập kỳ bắt đầu';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Vui lòng nhập số nguyên';
                              }
                              if (_endController.text.isNotEmpty &&
                                  int.tryParse(value)! >
                                      int.tryParse(_endController.text)!) {
                                return 'Kỳ bắt đầu phải nhỏ hơn hoặc bằng kỳ kết thúc';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _endController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Kỳ kết thúc',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Vui lòng nhập kỳ kết thúc';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Vui lòng nhập số nguyên';
                              }
                              if (_startController.text.isNotEmpty &&
                                  int.tryParse(value)! <
                                      int.tryParse(_startController.text)!) {
                                return 'Kỳ kết thúc phải lớn hơn hoặc bằng kỳ bắt đầu';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            bool hasConnectivity = await ConnectivityUtils
                                .checkConnectivityForFunction(context);
                            if (!hasConnectivity) {
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                startCode = int.tryParse(_startController.text);
                                endCode = int.tryParse(_endController.text);
                              });
                              getData(startCode!, endCode!);
                            }
                          },
                          child: Text('Thống kê'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Visibility(
                        visible: _viewColumnChart,
                        child: Expanded(
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Container(
                              height: 200,
                              padding: EdgeInsets.all(0),
                              child: charts.BarChart(
                                _createSampleData(),
                                animate: true,
                                domainAxis: charts.OrdinalAxisSpec(
                                  renderSpec: charts.SmallTickRendererSpec(
                                    labelStyle: charts.TextStyleSpec(
                                      fontSize: 5,
                                      color: charts.MaterialPalette.white,
                                    ),
                                    labelRotation: 0,
                                    labelAnchor:
                                        charts.TickLabelAnchor.centered,
                                  ),
                                ),
                                primaryMeasureAxis: charts.NumericAxisSpec(
                                  renderSpec: charts.GridlineRendererSpec(
                                    lineStyle: charts.LineStyleSpec(
                                      dashPattern: [4],
                                      color: charts.MaterialPalette.white,
                                    ),
                                  ),
                                ),
                                defaultInteractions: true,
                                selectionModels: [
                                  charts.SelectionModelConfig(
                                    type: charts.SelectionModelType.info,
                                    changedListener: _onSelectionChanged,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _viewColumnChart,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_downward,
                                  color: Colors.white),
                              onPressed: () {
                                sortColumnChartDescending();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh_rounded,
                                  color: Colors.white),
                              onPressed: () {
                                sortColumnChartAscending();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _viewColumnChart,
                    child: Text(
                        'Biểu đồ cột thống kê từ kỳ $startCode đến kỳ  ${startCode! + (numOfDrawPeriods - 1)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: _viewLineChart,
                    child: Expanded(
                      child: InteractiveViewer(
                        boundaryMargin: EdgeInsets.all(0),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Container(
                          height: 200,
                          padding: EdgeInsets.all(0),
                          child: charts.LineChart(
                            _createSampleLineChartData(),
                            animate: true,
                            domainAxis: charts.NumericAxisSpec(
                              renderSpec: charts.SmallTickRendererSpec(
                                labelStyle: charts.TextStyleSpec(
                                  fontSize: 5,
                                ),
                                labelRotation: 0,
                                labelAnchor: charts.TickLabelAnchor.centered,
                              ),
                            ),
                            primaryMeasureAxis: charts.NumericAxisSpec(
                              renderSpec: charts.GridlineRendererSpec(
                                lineStyle: charts.LineStyleSpec(
                                  dashPattern: [4],
                                ),
                              ),
                            ),
                            defaultInteractions: true,
                            selectionModels: [
                              charts.SelectionModelConfig(
                                type: charts.SelectionModelType.info,
                                changedListener: _onSelectionChanged,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewLineChart,
                    child: Text(
                        'Biểu đồ đường thống kê từ kỳ $startCode đến kỳ  ${startCode! + (numOfDrawPeriods - 1)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: _view55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _sortAscending = true;
                              sortFrequency();
                            });
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar(); // Đóng Snackbar hiện tại (nếu có)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đã sắp xếp danh sách theo thứ tự tăng dần'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Icon(Icons.arrow_upward, color: Colors.white),
                        ),
                        SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _sortAscending = false;
                              sortFrequency();
                            });
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar(); // Đóng Snackbar hiện tại (nếu có)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đã sắp xếp danh sách theo tần suất giảm dần'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child:
                              Icon(Icons.arrow_downward, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _view55,
                    child: Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            if (_view55)
                              for (var entry in frequency.entries)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '${entry.value} lần',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _winner,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Số người trúng jackpot 1: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              '$_jackpot1_winner',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Tổng tiền trúng jackpot 1: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Expanded(
                              child: Text(
                                '${NumberFormat('#,###', 'vi').format(_jackpot1_prize)}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Số người trúng jackpot 2: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              '$_jackpot2_winner',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Tổng tiền trúng jackpot 2: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Expanded(
                              child: Text(
                                '${NumberFormat('#,###', 'vi').format(_jackpot2_prize)}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }
}

class ChartData {
  final String number;
  final int count;

  ChartData(this.number, this.count);
}

class LineChartData {
  final int number;
  final int count;

  LineChartData(this.number, this.count);
}
