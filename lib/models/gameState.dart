// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameState {
  final String id;
  final List players;
  final bool isJoin;
  final bool isOver;
  final String winner;

  GameState( 
      {required this.id,
      required this.players,
      required this.isJoin,
      required this.isOver,
       this.winner = 'rat'
      });

  Map<String, dynamic> toJson() => {
        'id': id,
        'players': players,
        'isJoin': isJoin,
        'isOver': isOver,
        'winner' : winner
      };
}
