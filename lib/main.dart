import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const WaveCrashApp());

// --- DỮ LIỆU NGƯỜI DÙNG ---
class User {
  String username;
  String password;
  String displayName;
  double balance;
  bool isAdmin;
  User({
    required this.username,
    required this.password,
    this.displayName = "",
    this.balance = 0.0,
    this.isAdmin = false,
  });
}

// Khởi tạo Admin, khách đăng ký mới sẽ có 0đ
List<User> usersDb = [
  User(
    username: "phamhaicuong",
    password: "Haicuong@07",
    isAdmin: true,
    displayName: "ADMIN CƯỜNG",
    balance: 50000000.0,
  ),
];
User? currentUser;
double? nextForcedCrash;

class WaveCrashApp extends StatelessWidget {
  const WaveCrashApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF020617),
    ),
    home: const LoginScreen(),
  );
}

// --- MÀN HÌNH ĐĂNG KÝ ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final uCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  final dCtrl = TextEditingController();
  final capInput = TextEditingController();
  String captcha = "";
  @override
  void initState() {
    super.initState();
    _genCaptcha();
  }

  void _genCaptcha() =>
      setState(() => captcha = (Random().nextInt(8999) + 1000).toString());

  void _handleRegister() {
    if (uCtrl.text.isEmpty || pCtrl.text.isEmpty || dCtrl.text.isEmpty) return;
    if (capInput.text != captcha) {
      _genCaptcha();
      return;
    }
    // Khách đăng ký mới mặc định 0đ
    usersDb.add(
      User(
        username: uCtrl.text,
        password: pCtrl.text,
        displayName: dCtrl.text.toUpperCase(),
        balance: 0.0,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("ĐĂNG KÝ TÀI KHOẢN")),
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              TextField(
                controller: uCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên đăng nhập",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: pCtrl,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: dCtrl,
                decoration: const InputDecoration(
                  labelText: "Biệt danh (Nickname)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.blueGrey[900],
                    child: Text(
                      captcha,
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: capInput,
                      decoration: const InputDecoration(
                        hintText: "Mã xác nhận",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text("TẠO TÀI KHOẢN"),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// --- MÀN HÌNH ĐĂNG NHẬP ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final uCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  void _login() {
    try {
      currentUser = usersDb.firstWhere(
        (u) => u.username == uCtrl.text && u.password == pCtrl.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sai tài khoản!")));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "WAVE CRASH",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: uCtrl,
              decoration: const InputDecoration(
                labelText: "Tên đăng nhập",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: pCtrl,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text("ĐĂNG NHẬP"),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text("Đăng ký tài khoản mới"),
            ),
          ],
        ),
      ),
    ),
  );
}

// --- MÀN HÌNH GAME ---
enum GameState { waiting, flying, crashed }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  GameState _state = GameState.waiting;
  double multiplier = 1.0;
  int _waitTimer = 10;
  Timer? _timer;
  late AnimationController _bgCtrl;
  double _pendingBet = 0;
  double _activeBet = 0;
  bool _isBetConfirmed = false;
  double _lastWin = 0;
  bool _showWin = false;
  List<double> history = List.generate(
    10,
    (_) => 1.0 + Random().nextDouble() * 2,
  );

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startWait();
  }

  // --- HÀM ADMIN: QUẢN LÝ THÀNH VIÊN ---
  void _openAdmin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("DANH SÁCH THÀNH VIÊN"),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: usersDb.length,
                  itemBuilder: (context, i) {
                    final user = usersDb[i];
                    return ListTile(
                      title: Text(user.displayName),
                      subtitle: Text("${user.balance.toInt()}đ"),
                      trailing: const Icon(Icons.edit, size: 18),
                      onTap: () {
                        Navigator.pop(context);
                        _editBalance(user);
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Ép nổ ván tới (X)",
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (val) {
                  if (val.isNotEmpty) nextForcedCrash = double.tryParse(val);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ĐÓNG"),
          ),
        ],
      ),
    );
  }

  void _editBalance(User u) {
    final c = TextEditingController(text: u.balance.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sửa tiền: ${u.displayName}"),
        content: TextField(controller: c, keyboardType: TextInputType.number),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() => u.balance = double.parse(c.text));
              Navigator.pop(context);
              _openAdmin();
            },
            child: const Text("LƯU"),
          ),
        ],
      ),
    );
  }

  void _showDeposit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("NẠP TIỀN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Quét mã QR để nạp tiền vào game:"),
            const SizedBox(height: 15),
            Image.asset(
              'assets/QR.jpg',
              width: 250,
              errorBuilder: (c, e, s) => Container(
                height: 200,
                color: Colors.white,
                child: const Center(
                  child: Text(
                    "THIẾU FILE QR.jpg",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Nội dung: NAP ${currentUser?.username}",
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ĐÓNG"),
          ),
        ],
      ),
    );
  }

  void _showWithdraw() {
    String bank = "Vietcombank";
    final stk = TextEditingController();
    final amt = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, st) => AlertDialog(
          title: const Text("RÚT TIỀN"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: bank,
                isExpanded: true,
                items: ["Vietcombank", "MB Bank", "Techcombank", "BIDV"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => st(() => bank = v!),
              ),
              TextField(
                controller: stk,
                decoration: const InputDecoration(labelText: "Số tài khoản"),
              ),
              TextField(
                controller: amt,
                decoration: const InputDecoration(
                  labelText: "Số tiền muốn rút",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                double val = double.tryParse(amt.text) ?? 0;
                if (val > 0 && val <= currentUser!.balance) {
                  setState(() => currentUser!.balance -= val);
                  Navigator.pop(context);
                }
              },
              child: const Text("XÁC NHẬN"),
            ),
          ],
        ),
      ),
    );
  }

  void _startWait() {
    _bgCtrl.stop();
    if (mounted)
      setState(() {
        _state = GameState.waiting;
        _waitTimer = 10;
        multiplier = 1.0;
        _activeBet = 0;
        _pendingBet = 0;
        _showWin = false;
        _isBetConfirmed = false;
      });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_waitTimer > 0) {
        if (mounted) setState(() => _waitTimer--);
      } else {
        t.cancel();
        _startFly();
      }
    });
  }

  void _startFly() {
    setState(() => _state = GameState.flying);
    _bgCtrl.repeat();
    double crashAt = nextForcedCrash ?? (1.0 + Random().nextDouble() * 5.0);
    nextForcedCrash = null;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (mounted)
        setState(() {
          if (multiplier >= crashAt) {
            t.cancel();
            _handleCrash();
          } else {
            multiplier += 0.01 * (multiplier < 2 ? 1 : multiplier / 1.5);
          }
        });
    });
  }

  void _handleCrash() {
    _bgCtrl.stop();
    if (mounted)
      setState(() {
        _state = GameState.crashed;
        history.insert(0, multiplier);
        _isBetConfirmed = false;
      });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _startWait();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currentUser!.displayName,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // NÚT ĐĂNG XUẤT NHỎ CẠNH TÊN
                      InkWell(
                        onTap: () {
                          _timer?.cancel();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Đăng xuất",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (currentUser!.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.settings, size: 18),
                          onPressed: _openAdmin,
                        ),
                      Text(
                        "${currentUser!.balance.toInt()}đ",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _showDeposit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                    ),
                    child: const Text("NẠP"),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _showWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                    ),
                    child: const Text("RÚT"),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: history.length,
            itemBuilder: (c, i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: history[i] > 2 ? Colors.purple : Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Text("${history[i].toStringAsFixed(2)}x")),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder: (c, child) => Stack(
                    children: [
                      Positioned(
                        left: -(_bgCtrl.value * constraints.maxWidth),
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Image.asset(
                          'assets/duyenhai.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Container(color: Colors.black),
                        ),
                      ),
                      Positioned(
                        left:
                            constraints.maxWidth -
                            (_bgCtrl.value * constraints.maxWidth),
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Image.asset(
                          'assets/duyenhai.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Container(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_state == GameState.waiting)
                        Text(
                          "BẮT ĐẦU TRONG: $_waitTimer",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_state != GameState.waiting)
                        Text(
                          "${multiplier.toStringAsFixed(2)}x",
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            color: _state == GameState.crashed
                                ? Colors.red
                                : Colors.white,
                          ),
                        ),
                      if (_showWin)
                        Text(
                          "+${_lastWin.toInt()}đ",
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 60,
                  child: _state == GameState.crashed
                      ? Image.asset(
                          'assets/no1.png',
                          width: 200,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.flash_on, size: 80),
                        )
                      : Image.asset(
                          'assets/wave.png',
                          width: 200,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.motorcycle, size: 80),
                        ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.black,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _b(10000, "10K"),
                    _b(20000, "20K"),
                    _b(50000, "50K"),
                    _b(100000, "100K"),
                    _b(500000, "500K"),
                    _b(1000000, "1M"),
                    _b(10000000, "10M"),
                    _b(50000000, "50M"),
                    ActionChip(
                      label: const Text("ALL IN"),
                      onPressed: () =>
                          setState(() => _pendingBet = currentUser!.balance),
                    ),
                    ActionChip(
                      label: const Text("XÓA"),
                      onPressed: () => setState(() => _pendingBet = 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _state == GameState.waiting
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                  onPressed: () {
                    if (_state == GameState.waiting &&
                        !_isBetConfirmed &&
                        _pendingBet > 0 &&
                        currentUser!.balance >= _pendingBet) {
                      setState(() {
                        _isBetConfirmed = true;
                        _activeBet = _pendingBet;
                        currentUser!.balance -= _activeBet;
                      });
                    } else if (_state == GameState.flying && _isBetConfirmed) {
                      setState(() {
                        _lastWin = _activeBet * multiplier;
                        currentUser!.balance += _lastWin;
                        _showWin = true;
                        _isBetConfirmed = false;
                      });
                      Timer(
                        const Duration(seconds: 2),
                        () => setState(() => _showWin = false),
                      );
                    }
                  },
                  child: Text(
                    _state == GameState.waiting
                        ? (_isBetConfirmed
                              ? "ĐÃ CƯỢC ${_activeBet.toInt()}đ"
                              : "ĐẶT CƯỢC ${_pendingBet.toInt()}đ")
                        : (_isBetConfirmed
                              ? "CHỐT LỜI: +${(_activeBet * multiplier).toInt()}đ"
                              : "ĐANG CHẠY..."),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _b(double a, String l) => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: ActionChip(
      backgroundColor: Colors.red[900],
      label: Text(l),
      onPressed: () {
        if (_state == GameState.waiting && !_isBetConfirmed)
          setState(() => _pendingBet += a);
      },
    ),
  );
  @override
  void dispose() {
    _timer?.cancel();
    _bgCtrl.dispose();
    super.dispose();
  }
}
