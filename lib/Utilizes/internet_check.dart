import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';

enum BannerType { connected, slowInternet, disconnected }

class InternetService with ChangeNotifier {
  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;
  InternetService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> _init() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> result = await _connectivity
          .checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.other,
    );

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      notifyListeners();
    }
  }

  // Method to check with online operations
  bool checkConnection(BuildContext context, {bool showToast = true}) {
    if (!_isConnected && showToast) {
      SnackBarUtil.showErrorMessage(
        context,
        'No internet connection. Please try again.',
      );
    }
    return _isConnected;
  }
}

class InternetBanner extends StatefulWidget {
  final Widget child;
  final Duration connectedDisplayDuration;
  final String disconnectedText;
  final String connectedText;
  final String slowInternetText;
  final Color disconnectedColor;
  final Color connectedColor;
  final Color slowInternetColor;
  final Color textColor;
  final double height;
  final Duration animationDuration;
  final int slowInternetThreshold;

  const InternetBanner({
    super.key,
    required this.child,
    this.connectedDisplayDuration = const Duration(seconds: 3),
    this.disconnectedText = 'No Internet Connection',
    this.connectedText = 'Internet Connected',
    this.slowInternetText = 'Slow Internet Connection',
    this.disconnectedColor = Colors.red,
    this.connectedColor = Colors.green,
    this.slowInternetColor = Colors.orange,
    this.textColor = Colors.white,
    this.height = 100.0,
    this.animationDuration = const Duration(milliseconds: 500),
    this.slowInternetThreshold = 1000,
  });

  @override
  State<InternetBanner> createState() => _InternetBannerState();
}

class _InternetBannerState extends State<InternetBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final InternetService _internetService = InternetService();
  final bool _isConnected = false;
  bool _showBanner = false;
  BannerType _currentBannerType = BannerType.connected;
  Timer? _internetSpeedTimer;
  int _lastResponseTime = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _updateBannerState(_internetService.isConnected);
    _internetService.addListener(_onInternetStatusChanged);
    _startInternetSpeedMonitoring();
  }

  void _updateBannerState(bool isConnected) {
    if (!isConnected) {
      _currentBannerType = BannerType.disconnected;
      _showBanner = true;
      _animationController.forward();
    } else {
      _showBanner = false;
      _animationController.reverse();
    }
  }

  void _onInternetStatusChanged() {
    final isConnected = _internetService.isConnected;

    setState(() {
      if (!isConnected) {
        // Internet disconnected - show red banner immediately
        _currentBannerType = BannerType.disconnected;
        _showBanner = true;
        _animationController.forward();
      } else if (_currentBannerType == BannerType.disconnected) {
        // Internet reconnected - show green banner temporarily
        _currentBannerType = BannerType.connected;
        _showBanner = true;
        _animationController.forward();

        // Check speed immediately when reconnected
        _checkInternetSpeed();

        Future.delayed(widget.connectedDisplayDuration, () {
          if (mounted &&
              _internetService.isConnected &&
              _currentBannerType == BannerType.connected) {
            _animationController.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _showBanner = false;
                });
              }
            });
          }
        });
      }
    });
  }

  void _startInternetSpeedMonitoring() {
    _internetSpeedTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_isConnected) {
        _checkInternetSpeed();
      }
    });
  }

  Future<void> _checkInternetSpeed() async {
    final stopwatch = Stopwatch()..start();

    try {
      await Future.any([
        // Try multiple endpoints for better accuracy
        _testConnection('https://www.google.com/favicon.ico'),
        _testConnection('https://www.cloudflare.com/favicon.ico'),
        _testConnection('https://www.apple.com/favicon.ico'),
      ]);

      stopwatch.stop();
      _lastResponseTime = stopwatch.elapsedMilliseconds;

      if (mounted) {
        setState(() {
          if (_lastResponseTime > widget.slowInternetThreshold &&
              _isConnected) {
            _currentBannerType = BannerType.slowInternet;
            _showBanner = true;
            _animationController.forward();
          } else if (_lastResponseTime <= widget.slowInternetThreshold &&
              _currentBannerType == BannerType.slowInternet &&
              _isConnected) {
            // Speed improved, show connected banner
            _currentBannerType = BannerType.connected;
            _showBanner = true;
            _animationController.forward();

            Future.delayed(widget.connectedDisplayDuration, () {
              if (mounted &&
                  _isConnected &&
                  _currentBannerType == BannerType.connected) {
                _animationController.reverse().then((_) {
                  if (mounted) {
                    setState(() {
                      _showBanner = false;
                    });
                  }
                });
              }
            });
          }
        });
      }
    } catch (e) {
      stopwatch.stop();

      // If speed test fails, assume slow connection
      if (mounted && _isConnected) {
        setState(() {
          _currentBannerType = BannerType.slowInternet;
          _showBanner = true;
          _animationController.forward();
        });
      }
    }
  }

  Future<bool> _testConnection(String url) async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      await response.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Color get _bannerColor {
    switch (_currentBannerType) {
      case BannerType.connected:
        return widget.connectedColor;
      case BannerType.disconnected:
        return widget.disconnectedColor;
      case BannerType.slowInternet:
        return widget.slowInternetColor;
    }
  }

  String get _bannerText {
    switch (_currentBannerType) {
      case BannerType.connected:
        return widget.connectedText;
      case BannerType.disconnected:
        return widget.disconnectedText;
      case BannerType.slowInternet:
        return '${widget.slowInternetText} (${_lastResponseTime}ms)';
    }
  }

  Widget get _bannerIcon {
    switch (_currentBannerType) {
      case BannerType.connected:
        return Icon(Icons.wifi, color: widget.textColor, size: 24);
      case BannerType.disconnected:
        return Icon(Icons.wifi_off, color: widget.textColor, size: 24);
      case BannerType.slowInternet:
        return Icon(Icons.network_check, color: widget.textColor, size: 24);
    }
  }

  String get _bannerSubtitle {
    switch (_currentBannerType) {
      case BannerType.connected:
        return 'Connection is stable';
      case BannerType.disconnected:
        return 'Please check your network connection';
      case BannerType.slowInternet:
        return 'Loading may take longer than usual';
    }
  }

  @override
  void dispose() {
    _internetService.removeListener(_onInternetStatusChanged);
    _internetSpeedTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: widget.height,
                padding: EdgeInsets.only(top: statusBarHeight),
                decoration: BoxDecoration(
                  color: _bannerColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 18.0,
                      offset: const Offset(0, 4),
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bannerIcon,
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _bannerText,
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    _bannerSubtitle,
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            if (_currentBannerType == BannerType.disconnected ||
                                _currentBannerType == BannerType.slowInternet)
                              const SizedBox(width: 12.0),
                            if (_currentBannerType == BannerType.disconnected ||
                                _currentBannerType == BannerType.slowInternet)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.textColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
