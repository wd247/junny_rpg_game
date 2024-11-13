import 'dart:io';
import 'dart:math';

class Character {
  String name;
  int health;
  int attack;
  int defense;

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
  void startGame() {
    print('게임을 시작합니다!');
  }
}

void main() {
  var game = Game();
  game.startGame();
}
