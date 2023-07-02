import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'checking_all.dart';
import 'connectivity_utils.dart';

class CheckingScreen extends StatefulWidget {
  @override
  _CheckingScreenState createState() => _CheckingScreenState();
}

class _CheckingScreenState extends State<CheckingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _numberController1 = TextEditingController();
  TextEditingController _numberController2 = TextEditingController();
  TextEditingController _numberController3 = TextEditingController();
  TextEditingController _numberController4 = TextEditingController();
  TextEditingController _numberController5 = TextEditingController();
  TextEditingController _numberController6 = TextEditingController();
  String _numberController1result = "0";
  String _numberController2result = "0";
  String _numberController3result = "0";
  String _numberController4result = "0";
  String _numberController5result = "0";
  String _numberController6result = "0";
  String _numberControllerspecialresult = "0";
  String _drawDates = "";
  String _drawCodes = "";
  int _jackpot1prize = 0;
  int _jackpot2prize = 0;
  bool showResultJackpot1 = false;
  bool showResultJackpot2 = false;
  bool showResult1st = false;
  bool showResult2nd = false;
  bool showResult3rd = false;

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
  // Khai báo các giá trị cần thiết cho hoạt hình

  FocusNode _numberFocusNode1 = FocusNode();
  FocusNode _numberFocusNode2 = FocusNode();
  FocusNode _numberFocusNode3 = FocusNode();
  FocusNode _numberFocusNode4 = FocusNode();
  FocusNode _numberFocusNode5 = FocusNode();
  FocusNode _numberFocusNode6 = FocusNode();

  void _clearNumbers() {
    _numberController1.clear();
    _numberController2.clear();
    _numberController3.clear();
    _numberController4.clear();
    _numberController5.clear();
    _numberController6.clear();
  }

  @override
  void initState() {
    super.initState();
    _getDrawPeriods();
    ConnectivityUtils.checkConnectivity(context);
  }

  Future<void> _getDrawPeriods() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('vietlott_655_results')
          .orderBy('draw_period', descending: true)
          .get();
      _drawPeriods =
          result.docs.map((doc) => doc.get('draw_period').toString()).toList();
    } catch (e) {
      print(e);
    }
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Dò số 6/55'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 22, 25, 179),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'checkingAll') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => CheckingAllScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'checkingAll',
                child: Text('Chuyển đến màn hình dò tất cả'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 0),
                      child: Image.asset(
                        'assets/images/Power655.png',
                        width: 150.0,
                        height: 150.0,
                      ),
                    ),
                    Visibility(
                      visible: showResult,
                      child: Column(children: [
                        Text(
                          'Kết quả kỳ $_drawCodes, $_drawDates:',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _number1resultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberController1result,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      color: _number2resultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberController2result,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      color: _number3resultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberController3result,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      color: _number4resultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberController4result,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      color: _number5resultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberController5result,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      color: _number6resultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberController6result,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      color: _numberspecialresultBorderColor,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _numberControllerspecialresult,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Visibility(
                          visible: showResultJackpot1,
                          child: Text(
                            'Chúc mừng bạn đã trúng giải Jackpot1: \n${(_jackpot1prize).toStringAsFixed(0).replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (match) => '${match[1]}.',
                                ).toString()} VNĐ',
                            style: TextStyle(
                                color: Color.fromARGB(255, 30, 255, 49),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: (TextAlign.center),
                          ),
                        ), //jackpot1
                        Visibility(
                          visible: showResultJackpot2,
                          child: Text(
                            'Chúc mừng bạn đã trúng giải Jackpot2: \n${(_jackpot2prize).toStringAsFixed(0).replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (match) => '${match[1]}.',
                                ).toString()} VNĐ',
                            style: TextStyle(
                                color: Color.fromARGB(255, 30, 255, 49),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: (TextAlign.center),
                          ),
                        ), //jackpot2
                        Visibility(
                          visible: showResult1st,
                          child: Text(
                            'Chúc mừng bạn đã trúng giải Nhất \n40.000.000 đồng',
                            style: TextStyle(
                                color: Color.fromARGB(255, 30, 255, 49),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: (TextAlign.center),
                          ),
                        ),
                        Visibility(
                          visible: showResult2nd,
                          child: Text(
                            'Chúc mừng bạn đã trúng giải Nhì \n500.000 đồng',
                            style: TextStyle(
                                color: Color.fromARGB(255, 30, 255, 49),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: (TextAlign.center),
                          ),
                        ),
                        Visibility(
                          visible: showResult3rd,
                          child: Text(
                            'Chúc mừng bạn đã trúng giải Ba \n50.000 đồng',
                            style: TextStyle(
                                color: Color.fromARGB(255, 30, 255, 49),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: (TextAlign.center),
                          ),
                        ),
                        SizedBox(height: 20),
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
                                primary:
                                    Colors.transparent, // màu nền trong suốt
                                onSurface:
                                    Colors.white, // màu chữ khi không được nhấn
                                side: BorderSide(width: 1, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    SizedBox(height: 8),
                    Row(
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                focusNode: _numberFocusNode1,
                                onEditingComplete: () {
                                  _numberFocusNode1.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode2);
                                },
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                focusNode: _numberFocusNode2,
                                onEditingComplete: () {
                                  _numberFocusNode2.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode3);
                                },
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                focusNode: _numberFocusNode3,
                                onEditingComplete: () {
                                  _numberFocusNode3.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode4);
                                },
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                focusNode: _numberFocusNode4,
                                onEditingComplete: () {
                                  _numberFocusNode4.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode5);
                                },
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                focusNode: _numberFocusNode5,
                                onEditingComplete: () {
                                  _numberFocusNode5.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_numberFocusNode6);
                                },
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                focusNode: _numberFocusNode6,
                                onEditingComplete: () {
                                  _numberFocusNode6.unfocus();
                                  // FocusScope.of(context)
                                  //     .requestFocus(_numberFocusNode6);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _drawController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Chọn số kỳ',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        return _drawPeriods.where((period) => period
                            .toLowerCase()
                            .startsWith(pattern.toLowerCase()));
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        _drawController.text = suggestion;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        bool hasConnectivity = await ConnectivityUtils
                            .checkConnectivityForFunction(context);
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

                        if (_drawController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Thông báo'),
                              content: Text('Bạn chưa nhập kỳ'),
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
                                content: Text(
                                    'Các số phải nằm trong khoảng 1 đến 55'),
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

                        _number1resultBorderColor = Colors.white;
                        _number2resultBorderColor = Colors.white;
                        _number3resultBorderColor = Colors.white;
                        _number4resultBorderColor = Colors.white;
                        _number5resultBorderColor = Colors.white;
                        _number6resultBorderColor = Colors.white;
                        _numberspecialresultBorderColor = Colors.redAccent;

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
                          // Lấy ra các số đã được chọn
                          _selectedNumbers.clear();
                          _selectedNumbers
                              .add(int.parse(_numberController1.text));
                          _selectedNumbers
                              .add(int.parse(_numberController2.text));
                          _selectedNumbers
                              .add(int.parse(_numberController3.text));
                          _selectedNumbers
                              .add(int.parse(_numberController4.text));
                          _selectedNumbers
                              .add(int.parse(_numberController5.text));
                          _selectedNumbers
                              .add(int.parse(_numberController6.text));

                          // Lấy ra số kỳ đã chọn
                          final drawPeriod = int.parse(_drawController.text);

                          // Lấy ra thông tin kết quả xổ số từ Firebase
                          final result = await FirebaseFirestore.instance
                              .collection('vietlott_655_results')
                              .where('draw_period', isEqualTo: drawPeriod)
                              .get();

                          if (result.docs.isNotEmpty) {
                            final data = result.docs.first.data();
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
                            final drawCodes = data['draw_period'];
                            final drawDates = data['draw_date'];
                            _jackpot1prize = data['prize1_value'];
                            _jackpot2prize = data['prize2_value'];

                            if (winningNumbers.contains(
                                    int.parse(_numberController1.text)) ||
                                int.parse(_numberController1.text) ==
                                    specialNumber) {
                              setState(() {
                                _number1BorderColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _number1BorderColor = Colors.white;
                              });
                            }

                            if (winningNumbers.contains(
                                    int.parse(_numberController2.text)) ||
                                int.parse(_numberController2.text) ==
                                    specialNumber) {
                              setState(() {
                                _number2BorderColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _number2BorderColor = Colors.white;
                              });
                            }

                            if (winningNumbers.contains(
                                    int.parse(_numberController3.text)) ||
                                int.parse(_numberController3.text) ==
                                    specialNumber) {
                              setState(() {
                                _number3BorderColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _number3BorderColor = Colors.white;
                              });
                            }

                            if (winningNumbers.contains(
                                    int.parse(_numberController4.text)) ||
                                int.parse(_numberController4.text) ==
                                    specialNumber) {
                              setState(() {
                                _number4BorderColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _number4BorderColor = Colors.white;
                              });
                            }

                            if (winningNumbers.contains(
                                    int.parse(_numberController5.text)) ||
                                int.parse(_numberController5.text) ==
                                    specialNumber) {
                              setState(() {
                                _number5BorderColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _number5BorderColor = Colors.white;
                              });
                            }

                            if (winningNumbers.contains(
                                    int.parse(_numberController6.text)) ||
                                int.parse(_numberController6.text) ==
                                    specialNumber) {
                              setState(() {
                                _number6BorderColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _number6BorderColor = Colors.white;
                              });
                            }

                            setState(() {
                              _numberController1result =
                                  winningNumbers[0].toString();
                              _numberController2result =
                                  winningNumbers[1].toString();
                              _numberController3result =
                                  winningNumbers[2].toString();
                              _numberController4result =
                                  winningNumbers[3].toString();
                              _numberController5result =
                                  winningNumbers[4].toString();
                              _numberController6result =
                                  winningNumbers[5].toString();
                              _numberControllerspecialresult =
                                  specialNumber.toString();
                              _drawCodes = drawCodes.toString();
                              _drawDates = drawDates.toString();
                            });

                            for (int i = 0; i < 6; i++) {
                              if (winningNumbers
                                  .contains(_selectedNumbers[i])) {
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
                                    Colors.lightGreenAccent;
                              });
                            }

                            // Tính số lượng số trùng với các số trong kết quả xổ số
                            int matchingNumbers = 0;
                            for (int i = 0; i < _selectedNumbers.length; i++) {
                              if (winningNumbers
                                  .contains(_selectedNumbers[i])) {
                                matchingNumbers++;
                              }
                            }
                            // Kiểm tra số trùng với special number
                            bool hasSpecialNumber =
                                _selectedNumbers.contains(specialNumber);

                            // Xử lý kết quả trúng thưởng
                            if (matchingNumbers == 6) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text(
                                      'Chúc mừng bạn đã trúng JACKPOT 1 với giá trị ${(data['prize1_value']).toStringAsFixed(0).replaceAllMapped(
                                            RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                            (match) => '${match[1]}.',
                                          ).toString()} VNĐ'),
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
                              setState(() {
                                showResultJackpot1 = true;
                                showResultJackpot2 = false;
                                showResult1st = false;
                                showResult2nd = false;
                                showResult3rd = false;
                              });
                            } else if (matchingNumbers == 5 &&
                                hasSpecialNumber) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text(
                                      'Chúc mừng bạn đã trúng JACKPOT 2 với giá trị ${(data['prize2_value']).toStringAsFixed(0).replaceAllMapped(
                                            RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                            (match) => '${match[1]}.',
                                          ).toString()} VNĐ'),
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
                              setState(() {
                                showResultJackpot1 = false;
                                showResultJackpot2 = true;
                                showResult1st = false;
                                showResult2nd = false;
                                showResult3rd = false;
                              });
                            } else if (matchingNumbers == 5) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text(
                                      'Chúc mừng bạn đã trúng Giải Nhất với giá trị 40 triệu đồng'),
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
                              setState(() {
                                showResultJackpot1 = false;
                                showResultJackpot2 = false;
                                showResult1st = true;
                                showResult2nd = false;
                                showResult3rd = false;
                              });
                            } else if (matchingNumbers == 4) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text(
                                      'Chúc mừng bạn đã trúng Giải Nhì với giá trị 500.000 đồng'),
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
                              setState(() {
                                showResultJackpot1 = false;
                                showResultJackpot2 = false;
                                showResult1st = false;
                                showResult2nd = true;
                                showResult3rd = false;
                              });
                            } else if (matchingNumbers == 3) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text(
                                      'Chúc mừng bạn đã trúng Giải Ba với giá trị 50.000 đồng'),
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
                              setState(() {
                                showResultJackpot1 = false;
                                showResultJackpot2 = false;
                                showResult1st = false;
                                showResult2nd = false;
                                showResult3rd = true;
                              });
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text('Tiếc quá, không trúng rồi'),
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
                              setState(() {
                                showResultJackpot1 = false;
                                showResultJackpot2 = false;
                                showResult1st = false;
                                showResult2nd = false;
                                showResult3rd = false;
                              });
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Thông báo'),
                                content: Text('Không tìm thấy kết quả'),
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
                            setState(() {
                              showResultJackpot1 = false;
                              showResultJackpot2 = false;
                              showResult1st = false;
                              showResult2nd = false;
                              showResult3rd = false;
                            });
                          }
                          setState(() {
                            showResult = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, // Màu nền trong suốt
                        onSurface: Colors.white, // Màu chữ khi không được nhấn
                        side: BorderSide(width: 1, color: Colors.white),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: Text(
                          'Dò số',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
