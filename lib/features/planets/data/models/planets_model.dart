import 'package:flutter/material.dart';

class PlanetsModel {
  final String model;
  final String name;
  final String subtitle;
  final String imagePath;
  final Gradient gradient;
  final double width;
  final String distance;
  final String diameter;
  final String moons;
  final String atmosphere;
  final String temperature;
  final String? windSpeed;
  final String? description;

  const PlanetsModel({
    required this.model,
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.gradient,
    required this.width,
    required this.distance,
    required this.diameter,
    required this.moons,
    required this.atmosphere,
    required this.temperature,
    this.windSpeed,
    this.description,
  });
}

final List<PlanetsModel> planets = [
  PlanetsModel(
      model: "assets/models/mercury.glb",
      name: "Меркурий",
      subtitle: "Быстрый Вестник",
      imagePath: "assets/images/mercury.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.shade900,
          Colors.grey.shade500,
        ],
      ),
      width: 220,
      distance: "57.9 млн км",
      diameter: "4880 км",
      moons: "0",
      atmosphere: "Кислород, Натрий",
      temperature: "от -173 до 427°C",
      windSpeed: "Незначительная",
      description:
          "Меркурий — ближайшая к Солнцу и самая маленькая планета Солнечной системы. Ее поверхность каменистая, с экстремальными перепадами температур: сильная жара днем и ледяной холод ночью. У Меркурия почти нет атмосферы, чтобы удерживать тепло, а его поверхность покрыта кратерами, напоминая Луну."),
  PlanetsModel(
      model: "assets/models/venus.glb",
      name: "Венера",
      subtitle: "Вечерняя Звезда",
      imagePath: "assets/images/venus.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.orange.shade900,
          Colors.orange.shade300,
        ],
      ),
      width: 220,
      distance: "108.2 млн км",
      diameter: "12 104 км",
      moons: "0",
      atmosphere: "96.5% CO₂, 3.5% N₂",
      temperature: "Около 465°C",
      windSpeed: "~360 км/ч",
      description:
          "Венера — вторая планета от Солнца, схожая по размеру и составу с Землей, но с совершенно иными условиями. Ее плотные ядовитые облака из серной кислоты и температура поверхности, способная расплавить свинец, делают Венеру самой горячей планетой в Солнечной системе благодаря парниковому эффекту."),
  PlanetsModel(
      model: "assets/models/earth.glb",
      name: "Земля",
      subtitle: "Голубая Планета",
      imagePath: "assets/images/earth.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.shade900,
          Colors.blue.shade300,
        ],
      ),
      width: 220,
      distance: "149.6 млн км",
      diameter: "12 742 км",
      moons: "1",
      atmosphere: "78% N₂, 21% O₂",
      temperature: "от -88 до 58°C",
      windSpeed: "~32 км/ч",
      description:
          "Земля — третья планета от Солнца и единственная известная планета, поддерживающая жизнь. Она имеет разнообразную среду с обширными океанами, континентами и атмосферой, поддерживающей богатое разнообразие флоры и фауны. Атмосфера Земли состоит в основном из азота и кислорода, регулируя температуру и защищая жизнь от вредного солнечного излучения."),
  PlanetsModel(
      model: "assets/models/mars.glb",
      name: "Марс",
      subtitle: "Красная Планета",
      imagePath: "assets/images/mars.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.shade900,
          Colors.red.shade300,
        ],
      ),
      width: 220,
      distance: "227.9 млн км",
      diameter: "6792 км",
      moons: "2",
      atmosphere: "95% CO₂, 3% N₂",
      temperature: "от -125 до 20°C",
      windSpeed: "~97 км/ч",
      description:
          "Марс, четвертая планета от Солнца, известна как Красная планета из-за поверхности, богатой оксидом железа. У нее тонкая атмосфера, в основном из углекислого газа, и крупнейший вулкан и каньон в Солнечной системе. На Марсе есть сезоны, полярные шапки и следы древних водных потоков, что вызывает интерес к возможности жизни в прошлом или будущем."),
  PlanetsModel(
      model: "assets/models/jupiter.glb",
      name: "Юпитер",
      subtitle: "Газовый Гигант",
      imagePath: "assets/images/jupiter.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.brown.shade900,
          Colors.orange.shade400,
        ],
      ),
      width: 220,
      distance: "778.5 млн км",
      diameter: "139 820 км",
      moons: "79",
      atmosphere: "90% H₂, 10% He",
      temperature: "-108°C",
      windSpeed: "~640 км/ч",
      description:
          "Юпитер — крупнейшая планета Солнечной системы, газовый гигант, известный своими мощными бурями, включая Большое Красное Пятно — ураган, превышающий размер Земли и бушующий веками. С плотной атмосферой из водорода и гелия, Юпитер обладает сильным магнитным полем и более 70 спутниками, включая вулканический Ио и ледяную Европу."),
  PlanetsModel(
      model: "assets/models/saturn.glb",
      name: "Сатурн",
      subtitle: "Планета с Кольцами",
      imagePath: "assets/images/saturn.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.brown.shade900,
          Colors.amber.shade400,
        ],
      ),
      width: 220,
      distance: "1.43 млрд км",
      diameter: "116 460 км",
      moons: "83",
      atmosphere: "96% H₂, 3% He",
      temperature: "-139°C",
      windSpeed: "~1770 км/ч",
      description:
          "Сатурн — шестая планета от Солнца, наиболее известная своей потрясающей системой колец из частиц льда и камня. Газовый гигант, состоящий в основном из водорода и гелия, Сатурн менее плотный, чем вода. Его многочисленные спутники и уникальные атмосферные особенности, такие как гексагональная буря на северном полюсе, делают его одной из самых интригующих планет."),
  PlanetsModel(
      model: "assets/models/uranus.glb",
      name: "Уран",
      subtitle: "Ледяной Гигант",
      imagePath: "assets/images/uranus.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.teal.shade900,
          Colors.teal.shade300,
        ],
      ),
      width: 220,
      distance: "2.87 млрд км",
      diameter: "50 724 км",
      moons: "27",
      atmosphere: "83% H₂, 15% He",
      temperature: "-195°C",
      windSpeed: "~900 км/ч",
      description:
          "Уран — седьмая планета от Солнца, уникальная своим боковым вращением, вероятно, из-за массивного столкновения. Это ледяной гигант с холодной атмосферой, содержащей воду, метан и аммиак. Метан придает Урану голубовато-зеленый цвет, а также у него есть слабая система колец и множество спутников."),
  PlanetsModel(
      model: "assets/models/neptune.glb",
      name: "Нептун",
      subtitle: "Ветреная Планета",
      imagePath: "assets/images/neptune.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blueGrey.shade900,
          Colors.blue.shade300,
        ],
      ),
      width: 220,
      distance: "4.5 млрд км",
      diameter: "49 244 км",
      moons: "14",
      atmosphere: "80% H₂, 19% He",
      temperature: "-201°C",
      windSpeed: "~1930 км/ч",
      description:
          "Нептун — восьмая и самая далекая планета от Солнца, ледяной гигант с мощными ветрами и бурями, включая темное вращающееся пятно, известное как Большое Темное Пятно. Глубокий синий цвет обусловлен наличием метана в атмосфере. У Нептуна есть слабые кольца и 14 известных спутников, крупнейший из которых — Тритон."),
  PlanetsModel(
      model: "assets/models/pluto.glb",
      name: "Плутон",
      subtitle: "Карликовая Планета",
      imagePath: "assets/images/pluto.png",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.brown.shade900,
          Colors.grey.shade400,
        ],
      ),
      width: 220,
      distance: "5.9 млрд км",
      diameter: "2377 км",
      moons: "5",
      atmosphere: "Азот, Метан",
      temperature: "-229°C",
      windSpeed: "Незначительная",
      description:
          "Плутон, ранее считавшийся девятой планетой, теперь классифицируется как карликовая планета. Расположенный в поясе Койпера, он имеет каменисто-ледяную поверхность с горами, долинами и, возможно, подповерхностными океанами. У Плутона пять известных спутников, включая крупный Харон, и необычная орбита, которая иногда приближает его к Солнцу ближе, чем Нептун."),
];