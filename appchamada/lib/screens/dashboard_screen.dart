// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

// PLACEHOLDERS: Você deve mover estas classes e enum para lib/model/
enum RollCallStatus { pending, active, closed }

class RollCallRound extends Container{
  final int roundNumber;
  final RollCallStatus status;


  RollCallRound(this.roundNumber, {this.status = RollCallStatus.pending});

}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Container> _rounds = [];
  final CardSwiperController controller = CardSwiperController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Map<int, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _rounds = [      
      Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        color: Colors.blue,
        child: const Text('1'),
      ),
      Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        color: Colors.red,
        child: const Text('2'),
      ),
      Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        color: Colors.purple,
        child: const Text('3'),
      )
    ];
  }

  void _recordPresence(RollCallRound round) {
    if (round.status == RollCallStatus.active) {
      setState(() {
        _attendanceStatus[round.roundNumber] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Presença registrada na Rodada ${round.roundNumber}!'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A Rodada ${round.roundNumber} não está ativa.'))
      );
    }
  }

  Widget _buildRoundCard(RollCallRound round) {
    final bool isPresent = _attendanceStatus[round.roundNumber] ?? false;

    Color statusColor;
    String statusText;

    if (isPresent) {
      statusColor = Colors.green;
      statusText = 'PRESENTE (P)';
    } else if (round.status == RollCallStatus.active) {
      statusColor = Colors.blue;
      statusText = 'EM ANDAMENTO';
    } else if (round.status == RollCallStatus.closed) {
      statusColor = Colors.red;
      statusText = 'ENCERRADA';
    } else {
      statusColor = Colors.grey;
      statusText = 'A INICIAR';
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text('${round.roundNumber}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text('Rodada ${round.roundNumber}'),
        subtitle: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        trailing: isPresent
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: round.status == RollCallStatus.active
                    ? () => _recordPresence(round)
                    : null,
                child: const Text('Registrar'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Dashboard de Chamadas',
          style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, 
            color: Colors.white,),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navegar para Histórico (Futuro)')),
              );
            },
          ),
        ],
      ),
      body: Flexible(
        child: CardSwiper(
          controller: controller,
          cardsCount: _rounds.length,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) => _rounds[index],
        ),
      ),
    );
  }
}