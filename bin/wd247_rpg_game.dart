import 'dart:io';
import 'dart:math';

class Character {
  String name;
  int health;
  int attack;
  int defense;

  void attackMonster(Monster monster) {
    int damage = max(0, attack - monster.defense);
    monster.health -= damage;
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.');
  }

  Character(this.name, this.health, this.attack, this.defense);
}

class Monster {
  String name;
  int health;
  int attack;
  int defense = 0;

  Monster(this.name, this.health, this.attack);
}

class Game {
  late Character character;
  List<Monster> monsters = [];
  int killedMonster = 0;

  Game() {
    loadCharacterStats();
    // loadMonsterStats();
  }

  void loadCharacterStats() {
    try {
      final file =
          File('/Users/t2024-m0156/Desktop/proj/junny_rpg_game/characters.txt');
      final contents = file.readAsStringSync();
      final stats = contents.split(',');
      if (stats.length != 3) throw FormatException('Invalid character data');

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      String name = getCharacterName();
      character = Character(name, health, attack, defense);
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  void loadMonsterStats() {
    try {
      final file =
          File('/Users/t2024-m0156/Desktop/proj/junny_rpg_game/monters.txt');
      final lines = file.readAsLinesSync();
      for (var line in lines) {
        final stats = line.split(',');
        if (stats.length != 3) throw FormatException('Invalid monster data');

        String name = stats[0];
        int health = int.parse(stats[1]);
        int attack =
            max(this.character.defense, Random().nextInt(int.parse(stats[2])));

        monsters.add(Monster(name, health, attack));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  void loadMonstersStats() {}

  String getCharacterName() {
    while (true) {
      stdout.write('캐릭터의 이름을 입력하세요: ');
      String? input = stdin.readLineSync();
      if (input != null &&
          input.isNotEmpty &&
          RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(input)) {
        return input;
      }
      print('올바르지 않은 이름입니다. 한글 또는 영문 대소문자만 사용해주세요.');
    }
  }

  void startGame() {
    print('게임을 시작합니다!');
  }
}

void main() {
  var game = Game();
  game.startGame();
}
