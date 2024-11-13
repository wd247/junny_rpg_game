import 'dart:io';
import 'dart:math';
import 'dart:convert';

class Character {
  String name;
  int health;
  int attackPower;

  Character(this.name, this.health, this.attackPower);

  void attack(Monster target) {
    int damage = Random().nextInt(attackPower) + 1;
    target.takeDamage(damage);
    print('$name attacks ${target.name} for $damage damage!');
  }

  void takeDamage(int damage) {
    health -= damage;
    print('$name takes $damage damage! Remaining health: $health');
  }

  bool isAlive() {
    return health > 0;
  }
}

class Monster {
  String name;
  int health;
  int attackPower;

  Monster(this.name, this.health, this.attackPower);

  void attack(Character target) {
    int damage = Random().nextInt(attackPower) + 1;
    target.takeDamage(damage);
    print('$name attacks ${target.name} for $damage damage!');
  }

  void takeDamage(int damage) {
    health -= damage;
    print('$name takes $damage damage! Remaining health: $health');
  }

  bool isAlive() {
    return health > 0;
  }
}

class Game {
  late Character player;
  List<Monster> monsters = [];

  void startGame() async {
    await loadGameData();
    createPlayer();
    spawnMonsters();

    while (player.isAlive() && monsters.any((monster) => monster.isAlive())) {
      playerTurn();
      monsterTurn();
    }

    if (player.isAlive()) {
      print("You won!");
    } else {
      print("Game over. You lost.");
    }

    await saveGameData();
  }

  void createPlayer() {
    print("Enter your character's name: ");
    String? name = stdin.readLineSync();
    player = Character(name ?? 'Player', 100, 20);
  }

  void spawnMonsters() {
    List<String> monsterNames = ["Goblin", "Orc", "Dragon"];
    for (var name in monsterNames) {
      int health = Random().nextInt(71) + 30;
      int attackPower = Random().nextInt(16) + 5;
      monsters.add(Monster(name, health, attackPower));
    }
  }

  void playerTurn() {
    print("\nYour turn!");
    if (monsters.isNotEmpty) {
      Monster target = monsters[0];
      player.attack(target);
      if (!target.isAlive()) {
        print("${target.name} is defeated!");
        monsters.remove(target);
      }
    }
  }

  void monsterTurn() {
    print("\nMonsters' turn!");
    for (var monster in monsters) {
      if (monster.isAlive()) {
        monster.attack(player);
      }
    }
  }

  Future<void> loadGameData() async {
    try {
      var file = File('game_data.json');
      if (await file.exists()) {
        String contents = await file.readAsString();
        var data = jsonDecode(contents);
        print("Game data loaded: $data");
      } else {
        print("No game data found. Starting a new game.");
      }
    } catch (e) {
      print("Error loading game data: $e");
    }
  }

  Future<void> saveGameData() async {
    var data = {
      "player": {
        "name": player.name,
        "health": player.health,
        "attack_power": player.attackPower
      },
      "monsters": monsters
          .map((monster) => {
                "name": monster.name,
                "health": monster.health,
                "attack_power": monster.attackPower
              })
          .toList()
    };

    var file = File('game_data.json');
    await file.writeAsString(jsonEncode(data));
    print("Game data saved.");
  }
}

void main() {
  Game game = Game();
  game.startGame();
}
