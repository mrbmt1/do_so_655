import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

import 'checking_all.dart';
import 'connectivity_utils.dart';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  List<String> _topFrequentPairs = [];
  List<String> _topFrequentNumbers = [];
  List<String> _predictionNumbers = [];
  List<String> _topFrequentTriplets = [];
  List<String> _neverAppearedPairs = [];
  List<String> _topFrequentQuadruplets = [];
  List<String> _topFrequentQuintuplets = [];
  List<String> _topFrequentSextuplets = [];

  bool _isSextupletsLoaded = false;
  bool _isQuadrupletsLoaded = false;
  bool _isQuintupletsLoaded = false;
  bool _allPairsAppeared = false;

  bool _viewPredictLinearRegression = true;
  bool _viewNeverAppearedPairs = true;
  bool _viewTopFrequent = true;
  bool _viewPairs = true;
  bool _viewTriplets = true;
  bool _viewQuadruplets = true;
  bool _viewQuintuplets = true;
  bool _viewSextuplets = true;

  void listTopFrequentNumbers() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final numberCounts = Map<int, int>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      numbers.forEach((number) {
        numberCounts.update(number, (value) => value + 1, ifAbsent: () => 1);
      });
    });

    final sortedNumbers = numberCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = snapshot.size;

    final topFrequentNumbers = sortedNumbers
        .take(10)
        .map((entry) =>
            '${entry.key} (${entry.value} lần / $totalCount kỳ ~ ${((entry.value / totalCount) * 100).toStringAsFixed(2)}%/kỳ)')
        .toList();

    setState(() {
      _topFrequentNumbers = topFrequentNumbers;
    });
  }

  void predictLinearRegression() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      final numbers = [
        doc['number_1'] as num,
        doc['number_2'] as num,
        doc['number_3'] as num,
        doc['number_4'] as num,
        doc['number_5'] as num,
        doc['number_6'] as num,
        doc['special_number'] as num
      ];

      final input = Vector.fromList(
          numbers.sublist(0, 6).map((num) => num.toDouble()).toList());
      final output = Vector.fromList(
          [numbers.last.toDouble()]); // Chỉ lấy giá trị cuối cùng làm output

      return [input, output];
    }).toList();

    final inputs = Matrix.fromRows(data.map((row) => row[0]).toList());
    final outputs = Matrix.fromColumns(data.map((row) => row[1]).toList());

    final transposedInputs = inputs.transpose();
    final transposedOutputs = outputs.transpose();

    final coefficientMatrix = (transposedInputs * inputs).inverse() *
        transposedInputs *
        transposedOutputs;

    final predictions = inputs * coefficientMatrix;

    // Sắp xếp các số dự đoán theo thứ tự giảm dần
    final sortedPredictions = predictions.getColumn(0).toList();

    final distinctPredictions = <int>[];
    for (final prediction in sortedPredictions) {
      final predictionInt = prediction.toInt();
      if (!distinctPredictions.contains(predictionInt)) {
        distinctPredictions.add(predictionInt);
        if (distinctPredictions.length == 6) {
          break;
        }
      }
    }

    // Chuyển đổi các số dự đoán thành chuỗi và cập nhật giá trị của _predictionNumbers
    setState(() {
      _predictionNumbers =
          distinctPredictions.map((num) => num.toString()).toList();
    });
  }

  void listTopFrequentPairs() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final pairCounts = Map<String, int>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      final pairs = List.generate(numbers.length - 1, (index) {
        final firstNumber = numbers[index];
        final secondNumber = numbers[index + 1];
        return '${firstNumber}_${secondNumber}';
      });

      pairs.forEach((pair) {
        pairCounts.update(pair, (value) => value + 1, ifAbsent: () => 1);
      });
    });

    final sortedPairs = pairCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = snapshot.size;

    final topFrequentPairs = sortedPairs
        .take(10)
        .map((entry) =>
            '${entry.key.replaceAll('_', ' và ')} ( ${entry.value} lần/$totalCount kỳ )')
        .toList();

    setState(() {
      _topFrequentPairs = topFrequentPairs;
    });
  }

  void listTopFrequentTriplets() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final tripletCounts = Map<String, int>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      final triplets = List.generate(numbers.length - 2, (index) {
        final firstNumber = numbers[index];
        final secondNumber = numbers[index + 1];
        final thirdNumber = numbers[index + 2];
        return '${firstNumber}_${secondNumber}_${thirdNumber}';
      });

      triplets.forEach((triplet) {
        tripletCounts.update(triplet, (value) => value + 1, ifAbsent: () => 1);
      });
    });

    final sortedTriplets = tripletCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = snapshot.size;

    final topFrequentTriplets = sortedTriplets
        .take(10)
        .map((entry) =>
            '${entry.key.replaceAll('_', ', ')} ( ${entry.value} lần/$totalCount kỳ )')
        .toList();

    setState(() {
      _topFrequentTriplets = topFrequentTriplets;
    });
  }

  void listTopFrequentQuadruplets() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final quadrupletCounts = Map<String, int>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      final quadruplets = List.generate(numbers.length - 3, (index) {
        final firstNumber = numbers[index];
        final secondNumber = numbers[index + 1];
        final thirdNumber = numbers[index + 2];
        final fourthNumber = numbers[index + 3];
        return '${firstNumber}_${secondNumber}_${thirdNumber}_${fourthNumber}';
      });

      quadruplets.forEach((quadruplet) {
        quadrupletCounts.update(quadruplet, (value) => value + 1,
            ifAbsent: () => 1);
      });
    });

    final sortedQuadruplets = quadrupletCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = snapshot.size;

    final topFrequentQuadruplets = sortedQuadruplets
        .where((entry) => entry.value >= 2)
        .take(20)
        .map((entry) =>
            '${entry.key.replaceAll('_', ', ')} ( ${entry.value} lần/$totalCount kỳ )')
        .toList();

    setState(() {
      _topFrequentQuadruplets = topFrequentQuadruplets;
      _isQuadrupletsLoaded = true;
    });
  }

  void listTopFrequentQuintuplets() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final quintupletCounts = Map<String, int>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      final quintuplets = List.generate(numbers.length - 4, (index) {
        final firstNumber = numbers[index];
        final secondNumber = numbers[index + 1];
        final thirdNumber = numbers[index + 2];
        final fourthNumber = numbers[index + 3];
        final fifthNumber = numbers[index + 4];
        return '${firstNumber}_${secondNumber}_${thirdNumber}_${fourthNumber}_${fifthNumber}';
      });

      quintuplets.forEach((quintuplet) {
        quintupletCounts.update(quintuplet, (value) => value + 1,
            ifAbsent: () => 1);
      });
    });

    final sortedQuintuplets = quintupletCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = snapshot.size;

    final topFrequentQuintuplets = sortedQuintuplets
        .where((entry) => entry.value >= 2)
        .take(20)
        .map((entry) =>
            '${entry.key.replaceAll('_', ', ')} ( ${entry.value} lần/$totalCount kỳ )')
        .toList();

    setState(() {
      _topFrequentQuintuplets = topFrequentQuintuplets;
      _isQuintupletsLoaded = true;
    });
  }

  void listTopFrequentSextuplets() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: true)
        .get();

    final sextupletCounts = Map<String, int>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      final sextuplets = List.generate(numbers.length - 5, (index) {
        final firstNumber = numbers[index];
        final secondNumber = numbers[index + 1];
        final thirdNumber = numbers[index + 2];
        final fourthNumber = numbers[index + 3];
        final fifthNumber = numbers[index + 4];
        final sixthNumber = numbers[index + 5];
        return '${firstNumber}_${secondNumber}_${thirdNumber}_${fourthNumber}_${fifthNumber}_${sixthNumber}';
      });

      sextuplets.forEach((sextuplet) {
        sextupletCounts.update(sextuplet, (value) => value + 1,
            ifAbsent: () => 1);
      });
    });

    final sortedSextuplets = sextupletCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = snapshot.size;

    final topFrequentSextuplets = sortedSextuplets
        .where((entry) => entry.value >= 2)
        .take(20)
        .map((entry) =>
            '${entry.key.replaceAll('_', ', ')} ( ${entry.value} lần/$totalCount kỳ )')
        .toList();

    setState(() {
      _topFrequentSextuplets = topFrequentSextuplets;
      _isSextupletsLoaded = true;
    });
  }

  void listNeverAppearedPairs() async {
    bool hasConnectivity =
        await ConnectivityUtils.checkConnectivityForFunction(context);
    if (!hasConnectivity) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .orderBy('draw_period', descending: false)
        .get();

    final appearedPairs = Set<String>();

    snapshot.docs.forEach((doc) {
      final numbers = [
        doc['number_1'] as int,
        doc['number_2'] as int,
        doc['number_3'] as int,
        doc['number_4'] as int,
        doc['number_5'] as int,
        doc['number_6'] as int,
        doc['special_number'] as int,
      ];

      for (int i = 0; i < numbers.length - 1; i++) {
        for (int j = i + 1; j < numbers.length; j++) {
          final pair1 = '${numbers[i]}_${numbers[j]}';
          final pair2 = '${numbers[j]}_${numbers[i]}';

          appearedPairs.add(pair1);
          appearedPairs.add(pair2);
        }
      }
    });

    final neverAppearedPairs = <String>[];
    final totalCount = 55 * 54 ~/ 2;

    for (int i = 1; i <= 55; i++) {
      for (int j = i + 1; j <= 55; j++) {
        final pair = '${i}_$j';

        if (!appearedPairs.contains(pair)) {
          neverAppearedPairs.add(pair);
        }
      }
    }

    if (neverAppearedPairs.isEmpty) {
      setState(() {
        _allPairsAppeared = true;
      });
    } else {
      setState(() {
        _neverAppearedPairs = neverAppearedPairs;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ConnectivityUtils.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dự đoán 6/55'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 22, 25, 179),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'viewPredictLinearRegression':
                  setState(() {
                    _viewPredictLinearRegression =
                        !_viewPredictLinearRegression;
                  });
                  break;
                case 'viewTopFrequent':
                  setState(() {
                    _viewTopFrequent = !_viewTopFrequent;
                  });
                  break;
                case 'viewPairs':
                  setState(() {
                    _viewPairs = !_viewPairs;
                  });
                  break;
                case 'viewTriplets':
                  setState(() {
                    _viewTriplets = !_viewTriplets;
                  });
                  break;
                case 'viewQuadruplets':
                  setState(() {
                    _viewQuadruplets = !_viewQuadruplets;
                  });
                  break;
                case 'viewQuintuplets':
                  setState(() {
                    _viewQuintuplets = !_viewQuintuplets;
                  });
                  break;
                case 'viewSextuplets':
                  setState(() {
                    _viewSextuplets = !_viewSextuplets;
                  });
                  break;
                case 'viewNeverAppearedPairs':
                  setState(() {
                    _viewNeverAppearedPairs = !_viewNeverAppearedPairs;
                  });
                  break;
                case 'checkingAll':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CheckingAllScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'viewPredictLinearRegression',
                child: Text('Ẩn/hiện kết quả hồi quy tuyến tính'),
              ),
              PopupMenuItem<String>(
                value: 'viewTopFrequent',
                child: Text('Ẩn/hiện 10 số tần suất cao nhất'),
              ),
              PopupMenuItem<String>(
                value: 'viewPairs',
                child: Text('Ẩn/hiển 10 bộ 2 số xuất hiện nhiều nhất'),
              ),
              PopupMenuItem<String>(
                value: 'viewTriplets',
                child: Text('Ẩn/hiển 10 bộ 3 số xuất hiện nhiều nhất'),
              ),
              PopupMenuItem<String>(
                value: 'viewQuadruplets',
                child: Text('Ẩn/hiển các bộ 4 số xuất hiện nhiều nhất'),
              ),
              PopupMenuItem<String>(
                value: 'viewQuintuplets',
                child: Text('Ẩn/hiển các 5 số xuất hiện nhiều nhất'),
              ),
              PopupMenuItem<String>(
                value: 'viewSextuplets',
                child: Text('Ẩn/hiển các bộ 6 số xuất hiện nhiều nhất'),
              ),
              PopupMenuItem<String>(
                value: 'viewNeverAppearedPairs',
                child: Text('Ẩn/hiển bộ 2 chưa số xuất hiện cùng nhau'),
              ),
              PopupMenuItem<String>(
                value: 'checkingAll',
                child: Text('Chuyển đến màn hình dò tất cả các kỳ'),
              ),
            ],
          )
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20),
                children: [
                  Visibility(
                    visible: _viewPredictLinearRegression,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Kết quả từ dự đoán hồi quy tuyến tính(giảm dần từ trái sang phải):',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _predictionNumbers.isNotEmpty
                                  ? _predictionNumbers.join(' - ')
                                  : '',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: predictLinearRegression,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Dự đoán Hồi quy tuyến tính',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewTopFrequent,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewTopFrequent,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              '10 số có tần suất xuất hiện nhiều nhất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_topFrequentNumbers.isNotEmpty)
                              SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _topFrequentNumbers.length,
                              itemBuilder: (context, index) {
                                final number = _topFrequentNumbers[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Text(
                                    number,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listTopFrequentNumbers,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewPairs,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewPairs,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              '10 cặp số xuất hiện cùng nhau nhiều nhất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _topFrequentPairs.length,
                              itemBuilder: (context, index) {
                                final pair = _topFrequentPairs[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Text(
                                    pair,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listTopFrequentPairs,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewTriplets,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewTriplets,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'bộ 3 cặp số xuất hiện cùng nhau nhiều nhất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _topFrequentTriplets.length,
                              itemBuilder: (context, index) {
                                final triplet = _topFrequentTriplets[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Text(
                                    triplet,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listTopFrequentTriplets,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewQuadruplets,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewQuadruplets,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'bộ 4 cặp số xuất hiện cùng nhau nhiều nhất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (_isQuadrupletsLoaded)
                              if (_topFrequentQuadruplets.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _topFrequentQuadruplets.length,
                                  itemBuilder: (context, index) {
                                    final quadruplet =
                                        _topFrequentQuadruplets[index];
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: Text(
                                        quadruplet,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                Text(
                                  'Chưa có bộ 4 số nào xuất hiện cùng nhau ít nhất 2 lần',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                            if (!_isQuadrupletsLoaded)
                              SizedBox(
                                height: 10,
                              ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listTopFrequentQuadruplets,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewQuintuplets,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewQuintuplets,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'bộ 5 cặp số xuất hiện cùng nhau nhiều nhất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (_isQuintupletsLoaded)
                              if (_topFrequentQuintuplets.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _topFrequentQuintuplets.length,
                                  itemBuilder: (context, index) {
                                    final quintuplet =
                                        _topFrequentQuintuplets[index];
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: Text(
                                        quintuplet,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                Text(
                                  'Chưa có bộ 5 số nào xuất hiện cùng nhau ít nhất 2 lần',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                            if (!_isQuintupletsLoaded)
                              SizedBox(
                                height: 10,
                              ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listTopFrequentQuintuplets,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewSextuplets,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewSextuplets,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'bộ 6 cặp số xuất hiện cùng nhau nhiều nhất:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (_isSextupletsLoaded)
                              if (_topFrequentSextuplets.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _topFrequentSextuplets.length,
                                  itemBuilder: (context, index) {
                                    final sextuplet =
                                        _topFrequentSextuplets[index];
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: Text(
                                        sextuplet,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                Text(
                                  'Chưa có bộ 6 số nào xuất hiện ít nhất 2 lần',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                            if (!_isSextupletsLoaded)
                              SizedBox(
                                height: 10,
                              ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listTopFrequentSextuplets,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _viewNeverAppearedPairs,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible: _viewNeverAppearedPairs,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      color: Colors.white.withOpacity(0.01),
                      elevation: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Những bộ số chưa bao giờ xuất hiện cùng nhau:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (_allPairsAppeared)
                              Text(
                                'Tất cả các số đều đã xuất hiện cùng nhau',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _neverAppearedPairs.length,
                                itemBuilder: (context, index) {
                                  final pair = _neverAppearedPairs[index];

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    child: Text(
                                      pair,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: listNeverAppearedPairs,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                                primary: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                'Thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
