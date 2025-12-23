import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const WaveCrashApp());

class WaveCrashApp extends StatelessWidget {
  const WaveCrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
      ),
      home: const GameScreen(),
    );
  }
}

enum GameState { waiting, flying, crashed }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _gameState = GameState.waiting;
  double multiplier = 1.0;
  int _waitTimer = 10;
  Timer? _loopTimer;

  int _pendingBet = 0;
  int _activeBet = 0;
  double _balance = 30000000.0; // Tiền demo 30 triệu
  bool _hasConfirmedBet = false;

  // Biến phục vụ hiển thị tiền thắng
  double _lastWinAmount = 0;
  bool _showWinAnimation = false;

  List<double> history = List.generate(
    15,
    (index) => (Random().nextDouble() * 2) + 1.1,
  );

  @override
  void initState() {
    super.initState();
    _startWaitingPhase();
  }

  void _startWaitingPhase() {
    setState(() {
      _gameState = GameState.waiting;
      _waitTimer = 10;
      multiplier = 1.0;
      _hasConfirmedBet = false;
      _activeBet = 0;
      _pendingBet = 0;
      _showWinAnimation = false; // Tắt thông báo thắng khi sang ván mới
    });

    _loopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_waitTimer > 0)
          _waitTimer--;
        else {
          _loopTimer?.cancel();
          _startFlyingPhase();
        }
      });
    });
  }

  void _startFlyingPhase() {
    setState(() => _gameState = GameState.flying);
    // Tính toán điểm nổ ngẫu nhiên
    double crashPoint = 1.0 + (Random().nextDouble() * 5.0);
    if (Random().nextInt(10) == 0) crashPoint = 1.0;

    _loopTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (multiplier >= crashPoint)
          _handleCrash();
        else
          multiplier += 0.02 * (multiplier < 2 ? 1 : multiplier / 1.5);
      });
    });
  }

  void _handleCrash() {
    _loopTimer?.cancel();
    setState(() {
      _gameState = GameState.crashed;
      history.insert(0, multiplier);
      if (history.length > 20) history.removeLast();
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _startWaitingPhase();
    });
  }

  void _confirmBet() {
    if (_pendingBet > 0 && _balance >= _pendingBet) {
      setState(() {
        _balance -= _pendingBet;
        _activeBet = _pendingBet;
        _hasConfirmedBet = true;
      });
    }
  }

  void _cashOut() {
    if (_gameState == GameState.flying && _hasConfirmedBet) {
      double winAmount = _activeBet * multiplier;
      setState(() {
        _balance += winAmount; // Cộng tiền luôn
        _lastWinAmount = winAmount;
        _showWinAnimation = true; // Hiện thông báo ăn bao nhiêu tiền
        _hasConfirmedBet = false; // Đã rút thành công
      });

      // Tự động ẩn thông báo thắng sau 2 giây
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showWinAnimation = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildHistoryBar(),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_gameState == GameState.waiting)
                            _buildWaitingDisplay(),
                          if (_gameState != GameState.waiting)
                            _buildFlyingDisplay(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DUYÊN HẢI TÔI YÊU",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Tác giả: PHẠM HẢI CƯỜNG",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Text(
              "${_balance.toInt()}đ",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryBar() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: history.length,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: history[i] > 2 ? Colors.purple : Colors.blueGrey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              "${history[i].toStringAsFixed(2)}x",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingDisplay() {
    return Container(
      color: const Color(0xFF0B1120),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "CHUẨN BỊ BỐC",
            style: TextStyle(
              color: Color(0xFF94A3B8),
              letterSpacing: 4,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "$_waitTimer",
            style: const TextStyle(
              fontSize: 110,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF87171),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlyingDisplay() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/duyenhai.png', fit: BoxFit.cover),
        ),

        // Hiển thị Multiplier và Thông báo tiền ăn được
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${multiplier.toStringAsFixed(2)}x",
                style: TextStyle(
                  fontSize: 85,
                  fontWeight: FontWeight.w900,
                  color: _gameState == GameState.crashed
                      ? Colors.red
                      : Colors.white,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 25)],
                ),
              ),
              if (_showWinAnimation)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "+${_lastWinAmount.toInt()}đ",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Xe Wave chạy và nổ (no1.png)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          bottom: _gameState == GameState.crashed ? 50 : 45 + (multiplier * 15),
          left: _gameState == GameState.crashed ? 280 : (multiplier * 90) - 80,
          child: _gameState == GameState.crashed
              ? Image.asset('assets/no1.png', width: 180)
              : Transform.rotate(
                  angle: -0.12,
                  child: Image.asset(
                    'assets/wave.png',
                    width: 200,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.motorcycle,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBottomControl() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: const Color(0xFF111827),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              10000,
              50000,
              100000,
              500000,
            ].map((v) => _chip(v)).toList(),
          ),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, height: 60, child: _actionButton()),
        ],
      ),
    );
  }

  Widget _chip(int val) {
    return GestureDetector(
      onTap: () => setState(() {
        if (_gameState == GameState.waiting) _pendingBet += val;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Text(
          "${(val / 1000).toInt()}K",
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _actionButton() {
    if (_gameState == GameState.waiting) {
      return ElevatedButton(
        onPressed: _hasConfirmedBet ? null : _confirmBet,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _hasConfirmedBet
              ? "ĐÃ CƯỢC: ${_activeBet}đ"
              : "ĐẶT CƯỢC ($_pendingBetđ)",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: (_hasConfirmedBet && _gameState == GameState.flying)
            ? _cashOut
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _hasConfirmedBet && _gameState == GameState.flying
              ? "NHẬN THƯỞNG (${(multiplier * _activeBet).toInt()}đ)"
              : "ĐANG BỐC...",
        ),
      );
    }
  }
}
