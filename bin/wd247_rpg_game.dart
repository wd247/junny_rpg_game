import 'dart:io';
import 'dart:math';

class Character {
  String name;
  int health;
  int attack;
  int defense;
  bool usedItem = false; //아이템 사용 여부를 확인하기 위한 변수

  Character(this.name, this.health, this.attack, this.defense);

  void attackMonster(Monster monster) {
    int damage = max(0, attack - monster.defense);
    monster.health -= damage;
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.');
  }

  void defend(int monsterAttack) {
    int damage = monsterAttack - defense;
    health += damage;

    print('$name이(가) 방어 태세를 취하여 $damage 만큼 체력을 얻었습니다.');
  }

  //아이템 사용 함수 추가
  void useItem() {
    if (!usedItem) {
      print('특수 아이템을 사용하여 ${name}의 공격력이 두 배가 됩니다!');
      attack *= 2; // 한 턴 동안 공격력 2배 처리
      usedItem = true; // 아이템 사용 완료 처리
    } else {
      print('이미 특수 아이템을 사용하셨습니다.');
    }
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}

class Monster {
  String name;
  int health;
  int attack;
  int defense = 0;
  int increaseDefenceCount = 0; // 방어력 증가 턴 카운팅 변수

  Monster(this.name, this.health, this.attack);

  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense);
    character.health -= damage;
    print('${this.name}이(가) ${character.name}에게 $damage의 데미지를 입혔습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack');
  }

  //몬스터의 방어력 증가 기능 추가
  void increaseDefence() {
    defense += 2; // 방어력 증가략
    increaseDefenceCount = 0; // 턴 카운터 초기화
    print('${name}의 방어력이 증가했습니다! 현재 방어력: $defense');
  }
}

class Game {
  late Character character;
  List<Monster> monsters = [];
  int killedMonster = 0;

  Game() {
    loadCharacterStats();
    giveBonusHealth(); // 도전1
    loadMonsterStats();
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

  // 캐릭터의 체력 증가 기능 추가 함수
  void giveBonusHealth() {
    Random random = Random();
    if (random.nextInt(30) == 0) {
      character.health += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: ${character.health}');
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

  Monster getRandomMonster() {
    if (monsters.isEmpty) {
      throw StateError('몬스터 리스트가 비어있습니다.');
    }

    return monsters[Random().nextInt(monsters.length)];
  }

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
    character.showStatus();

    while (true) {
      Monster currentMonster = getRandomMonster();
      print('\n새로운 몬스터가 나타났습니다!');
      currentMonster.showStatus();

      battle(currentMonster);

      if (character.health <= 0) {
        print('게임 오버! ${character.name}이(가) 쓰러졌습니다.');
        saveResult(false);
        return;
      }

      if (killedMonster == 2) {
        print('\n축하합니다! 모든 몬스터를 물리쳤습니다.');
        saveResult(true);
        return;
      }

      print('\n다음 몬스터와 싸우시겠습니까? (y/n): ');
      String? response = stdin.readLineSync();

      if (response?.toLowerCase() != 'y') {
        print('게임을 종료합니다.');
        saveResult(true);
        return;
      }
    }
  }

  void battle(Monster monster) {
    while (monster.health > 0 && character.health > 0) {
      print('\n${character.name}의 턴');
      stdout.write('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용): ');
      String? action = stdin.readLineSync();
      if (action == '1') {
        character.attackMonster(monster);
      } else if (action == '2') {
        character.defend(monster.attack);
      } else if (action == '3') {
        character.useItem(); // 3 입력 시 아이템 사용 함수 호출
      } else {
        print('잘못된 입력입니다. 다시 선택해주세요.');
        continue;
      }

      // 카운트 변수 increateDefenceCount를 1씩 증가
      monster.increaseDefenceCount++;
      if (monster.increaseDefenceCount >= 3) {
        monster.increaseDefence(); //3턴마다 방어력 증가 함수 호출
      }

      if (monster.health <= 0) {
        print('${monster.name}을(를) 물리쳤습니다!');
        monsters.remove(monster);
        killedMonster++;
        break;
      }

      print('\n${monster.name}의 턴');

      monster.attackCharacter(character);

      character.showStatus();
      monster.showStatus();
    }
  }

  void saveResult(bool victory) {
    stdout.write('결과를 저장하시겠습니까? (y/n): ');
    String? response = stdin.readLineSync();
    if (response?.toLowerCase() == 'y') {
      try {
        final file = File('result.txt');
        final result = victory ? '승리' : '패배';
        file.writeAsStringSync(
            '캐릭터: ${character.name}, 남은 체력: ${character.health}, 결과: $result');
        print('결과가 저장되었습니다.');
      } catch (e) {
        print('결과 저장에 실패했습니다: $e');
      }
    }
  }
}

void main() {
  var game = Game();
  game.startGame();
}
