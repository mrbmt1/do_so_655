import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'connectivity_utils.dart';

class CheckingAllScreen extends StatefulWidget {
  @override
  _CheckingAllScreenState createState() => _CheckingAllScreenState();
}

class _CheckingAllScreenState extends State<CheckingAllScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _numberController1 = TextEditingController();
  TextEditingController _numberController2 = TextEditingController();
  TextEditingController _numberController3 = TextEditingController();
  TextEditingController _numberController4 = TextEditingController();
  TextEditingController _numberController5 = TextEditingController();
  TextEditingController _numberController6 = TextEditingController();

  List<Map<String, dynamic>> lotteryResults = [];

  final _drawController = TextEditingController();
  List<int> _selectedNumbers = [];
  List<String> _drawPeriods = [];
  bool showResult = false;
  Color _number1BorderColor = Colors.white;
  Color _number2BorderColor = Colors.white;
  Color _number3BorderColor = Colors.white;
  Color _number4BorderColor = Colors.white;
  Color _number5BorderColor = Colors.white;
  Color _number6BorderColor = Colors.white;
  Color _number1resultBorderColor = Colors.white;
  Color _number2resultBorderColor = Colors.white;
  Color _number3resultBorderColor = Colors.white;
  Color _number4resultBorderColor = Colors.white;
  Color _number5resultBorderColor = Colors.white;
  Color _number6resultBorderColor = Colors.white;
  Color _numberspecialresultBorderColor = Colors.redAccent;

  FocusNode _numberFocusNode1 = FocusNode();
  FocusNode _numberFocusNode2 = FocusNode();
  FocusNode _numberFocusNode3 = FocusNode();
  FocusNode _numberFocusNode4 = FocusNode();
  FocusNode _numberFocusNode5 = FocusNode();
  FocusNode _numberFocusNode6 = FocusNode();

  bool _viewTriplets = false;
  bool _viewQuadruplets = false;
  bool _viewQuintuplets = false;
  bool _viewSextuplets = false;
  bool _viewAllResults = true;
  bool hasMatchingResults = false;
  bool isLoading = false;

  bool isNumberMatching(int number) {
    return _selectedNumbers.contains(number);
  }

  void _clearNumbers() {
    _numberController1.clear();
    _numberController2.clear();
    _numberController3.clear();
    _numberController4.clear();
    _numberController5.clear();
    _numberController6.clear();
  }

  int getMatchingNumbersCount(Map<String, dynamic> result) {
    int count = 0;
    for (var number in result['winningNumbers']) {
      if (isNumberMatching(number)) {
        count++;
      }
    }
    if (result['specialNumber'] != null &&
        isNumberMatching(result['specialNumber'])) {
      count++;
    }
    return count;
  }

  void showResultDetails(int drawPeriod) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_results')
        .where('draw_period', isEqualTo: drawPeriod)
        .get();

    if (snapshot.size > 0) {
      final result = snapshot.docs[0].data();
      final drawDate = result['draw_date'] as String;
      final prize1Value = result['prize1_value'] as int;
      final prize2Value = result['prize2_value'] as int;
      final jackpot1Winner = result['jackpot1_winner'] as int;
      final jackpot2Winner = result['jackpot2_winner'] as int;

      final currencyFormat =
          NumberFormat.decimalPattern('vi'); // Định dạng tiền tệ
      final formattedPrize1Value = currencyFormat.format(prize1Value);
      final formattedPrize2Value = currencyFormat.format(prize2Value);

      final message = 'Kỳ: ${drawPeriod.toString().padLeft(4, '0')}\n'
          'Ngày xổ: $drawDate\n'
          'Giá trị Jackpot 1: ${formattedPrize1Value} VNĐ\n'
          'Giá trị Jackpot 2: ${formattedPrize2Value} VNĐ\n'
          'Số người trúng jackpot 1: ${jackpot1Winner.toString()}\n'
          'Số người trúng jackpot 2: ${jackpot2Winner.toString()}';

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    ConnectivityUtils.checkConnectivity(context);
  }

  @override
  void dispose() {
    _numberController1.dispose();
    _numberController2.dispose();
    _numberController3.dispose();
    _numberController4.dispose();
    _numberController5.dispose();
    _numberController6.dispose();
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dò tất cả số 6/55'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 22, 25, 179),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _viewTriplets = false;
                _viewQuadruplets = false;
                _viewQuintuplets = false;
                _viewSextuplets = false;
                _viewAllResults = false;
                switch (value) {
                  case 'viewTriplets':
                    _viewTriplets = true;
                    break;
                  case 'viewQuadruplets':
                    _viewQuadruplets = true;
                    break;
                  case 'viewQuintuplets':
                    _viewQuintuplets = true;
                    break;
                  case 'viewSextuplets':
                    _viewSextuplets = true;
                    break;
                  case 'viewAllResults':
                    _viewAllResults = true;
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'viewTriplets',
                child: Text('Hiển thị kết quả trùng ít nhất 3 cặp số'),
              ),
              PopupMenuItem<String>(
                value: 'viewQuadruplets',
                child: Text('Hiển thị kết quả trùng ít nhất 4 cặp số'),
              ),
              PopupMenuItem<String>(
                value: 'viewQuintuplets',
                child: Text('Hiển thị kết quả trùng ít nhất 5 cặp số'),
              ),
              PopupMenuItem<String>(
                value: 'viewSextuplets',
                child: Text('Hiển thị kết quả trùng ít nhất 6 cặp số'),
              ),
              PopupMenuItem<String>(
                value: 'viewAllResults',
                child: Text('Hiển thị tất cả kết quả'),
              ),
            ],
          ),
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
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Số của bạn chọn:',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _clearNumbers();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Xóa hết số',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent, // màu nền trong suốt
                          onSurface:
                              Colors.white, // màu chữ khi không được nhấn
                          side: BorderSide(width: 1, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _number1BorderColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: TextFormField(
                                controller: _numberController1,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                validator: (value) {
                                  return null;
                                },
                                focusNode: _numberFocusNode1,
                                onEditingComplete: () {
                                  _numberFocusNode1.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode2);
                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _number2BorderColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: TextFormField(
                                controller: _numberController2,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                validator: (value) {
                                  return null;
                                },
                                focusNode: _numberFocusNode2,
                                onEditingComplete: () {
                                  _numberFocusNode2.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode3);
                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _number3BorderColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: TextFormField(
                                controller: _numberController3,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                validator: (value) {
                                  return null;
                                },
                                focusNode: _numberFocusNode3,
                                onEditingComplete: () {
                                  _numberFocusNode3.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode4);
                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _number4BorderColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: TextFormField(
                                controller: _numberController4,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                validator: (value) {
                                  return null;
                                },
                                focusNode: _numberFocusNode4,
                                onEditingComplete: () {
                                  _numberFocusNode4.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode5);
                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _number5BorderColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: TextFormField(
                                controller: _numberController5,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                validator: (value) {
                                  return null;
                                },
                                focusNode: _numberFocusNode5,
                                onEditingComplete: () {
                                  _numberFocusNode5.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode6);
                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _number6BorderColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: TextFormField(
                                controller: _numberController6,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                validator: (value) {
                                  return null;
                                },
                                focusNode: _numberFocusNode6,
                                onEditingComplete: () {
                                  _numberFocusNode6.unfocus();
                                  // FocusScope.of(context)
                                  //     .requestFocus(_numberFocusNode6);
                                },
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Visibility(
                child: ElevatedButton(
                  onPressed: () async {
                    bool hasConnectivity =
                        await ConnectivityUtils.checkConnectivityForFunction(
                            context);
                    if (!hasConnectivity) {
                      return;
                    }
                    List<int> numbers = [
                      int.tryParse(_numberController1.text) ?? 0,
                      int.tryParse(_numberController2.text) ?? 0,
                      int.tryParse(_numberController3.text) ?? 0,
                      int.tryParse(_numberController4.text) ?? 0,
                      int.tryParse(_numberController5.text) ?? 0,
                      int.tryParse(_numberController6.text) ?? 0,
                    ];

                    // Check for empty input fields
                    if (_numberController1.text.isEmpty ||
                        _numberController2.text.isEmpty ||
                        _numberController3.text.isEmpty ||
                        _numberController4.text.isEmpty ||
                        _numberController5.text.isEmpty ||
                        _numberController6.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Thông báo'),
                          content: Text('Bạn chưa nhập đủ các số'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            )
                          ],
                        ),
                      );
                      return;
                    }

                    // Check for numbers less than 55
                    for (int i = 0; i < numbers.length; i++) {
                      if (numbers[i] < 1 || numbers[i] > 55) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Thông báo'),
                            content:
                                Text('Các số phải nằm trong khoảng 1 đến 55'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              )
                            ],
                          ),
                        );
                        return;
                      }
                    }

                    // Check for duplicate numbers
                    if (numbers.toSet().length != numbers.length) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Thông báo'),
                          content: Text('Các số không được trùng nhau'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            )
                          ],
                        ),
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      // Lấy ra các số đã được chọn
                      _selectedNumbers.clear();
                      _selectedNumbers.add(int.parse(_numberController1.text));
                      _selectedNumbers.add(int.parse(_numberController2.text));
                      _selectedNumbers.add(int.parse(_numberController3.text));
                      _selectedNumbers.add(int.parse(_numberController4.text));
                      _selectedNumbers.add(int.parse(_numberController5.text));
                      _selectedNumbers.add(int.parse(_numberController6.text));

                      // Lấy ra số kỳ đã chọn

                      // Lấy ra thông tin kết quả xổ số từ Firebase
                      final result = await FirebaseFirestore.instance
                          .collection('vietlott_655_results')
                          .orderBy('draw_period', descending: true)
                          .get();

                      if (result.docs.isNotEmpty) {
                        lotteryResults.clear();
                        for (var doc in result.docs) {
                          final data = doc.data();
                          // Lấy ra các số đã trúng
                          final winningNumbers = [
                            data['number_1'],
                            data['number_2'],
                            data['number_3'],
                            data['number_4'],
                            data['number_5'],
                            data['number_6']
                          ];
                          final specialNumber = data['special_number'];
                          final drawPeriod = data['draw_period'];
                          final drawDate = data['draw_date'];

                          Map<String, dynamic> lotteryResult = {
                            'winningNumbers': winningNumbers,
                            'specialNumber': specialNumber,
                            'drawPeriod': drawPeriod,
                            'drawDate': drawDate,
                          };

                          lotteryResults.add(lotteryResult);

                          for (int i = 0; i < 6; i++) {
                            if (winningNumbers.contains(_selectedNumbers[i])) {
                              int index =
                                  winningNumbers.indexOf(_selectedNumbers[i]);
                              setState(() {
                                if (index == 0) {
                                  _number1resultBorderColor = Colors.green;
                                } else if (index == 1) {
                                  _number2resultBorderColor = Colors.green;
                                } else if (index == 2) {
                                  _number3resultBorderColor = Colors.green;
                                } else if (index == 3) {
                                  _number4resultBorderColor = Colors.green;
                                } else if (index == 4) {
                                  _number5resultBorderColor = Colors.green;
                                } else if (index == 5) {
                                  _number6resultBorderColor = Colors.green;
                                }
                              });
                            }
                          }
                          if (specialNumber != null &&
                              _selectedNumbers.contains(specialNumber)) {
                            setState(() {
                              _numberspecialresultBorderColor =
                                  Color.fromARGB(255, 4, 0, 255);
                            });
                          }
                        }
                        setState(() {
                          showResult = true;
                        });
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent, // Màu nền trong suốt
                    onSurface: Colors.white, // Màu chữ khi không được nhấn
                    side: BorderSide(width: 1, color: Colors.white),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Text(
                      'Dò số',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                child: Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Visibility(
                          visible: isLoading,
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text(
                                'Dữ liệu rất lớn, đang tải dữ liệu...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showResult)
                          Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: lotteryResults.length,
                                itemBuilder: (context, index) {
                                  var result = lotteryResults[index];
                                  return Column(
                                    children: [
                                      if ((_viewTriplets &&
                                              getMatchingNumbersCount(result) >=
                                                  3) ||
                                          (_viewQuadruplets &&
                                              getMatchingNumbersCount(result) >=
                                                  4) ||
                                          (_viewQuintuplets &&
                                              getMatchingNumbersCount(result) >=
                                                  5) ||
                                          (_viewSextuplets &&
                                              getMatchingNumbersCount(result) >=
                                                  6) ||
                                          _viewAllResults)
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 3),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Kỳ: ',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${result['drawPeriod']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Ngày: ',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${result['drawDate']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(''),
                                                for (var number
                                                    in result['winningNumbers'])
                                                  GestureDetector(
                                                    onTap: () {
                                                      showResultDetails(
                                                          result['drawPeriod']);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 1),
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                isNumberMatching(
                                                                        number)
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .white,
                                                            width: 2,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '$number',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (result['specialNumber'] !=
                                                    null)
                                                  GestureDetector(
                                                    onTap: () {
                                                      showResultDetails(
                                                          result['drawPeriod']);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4),
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: isNumberMatching(
                                                                    result[
                                                                        'specialNumber'])
                                                                ? Colors.green
                                                                : Colors
                                                                    .redAccent,
                                                            width: 2,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${result['specialNumber']}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
