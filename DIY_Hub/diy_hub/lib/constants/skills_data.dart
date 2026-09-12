// lib/constants/skills_data.dart
// Static seed content for all missions (skills) shown in the app.
// Replace/expand this list later, or swap for a JSON/remote source —
// nothing else in the app needs to change since screens only read SkillModel.

import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/skill_model.dart';
import 'app_colors.dart';

class SkillsData {
  SkillsData._();

  static const String electronics = 'Electronics & Gadget Lab';
  static const String homeRepair = 'Home Repair';
  static const String woodcraft = 'Woodcraft';
  static const String cookingLab = 'Cooking Lab';
  static const String robotics = 'Robotics';
  static const String gardening = 'Gardening & Eco';

  static const List<String> allCategories = [
    electronics,
    homeRepair,
    woodcraft,
    cookingLab,
    robotics,
    gardening,
  ];

  static List<LessonModel> _lessons(String skillId, List<String> titles, List<List<String>> stepsPerLesson) {
    return List.generate(titles.length, (i) {
      return LessonModel(
        id: '${skillId}_l${i + 1}',
        title: titles[i],
        steps: stepsPerLesson[i],
        order: i + 1,
      );
    });
  }

  static final List<SkillModel> all = [
    // ── Electronics & Gadget Lab ───────────────────────────────────
    SkillModel(
      id: 'electric_lemon_clock',
      title: 'Electric Lemon Battery Clock',
      category: electronics,
      description:
          'Harness citric acid chemical reactions to power an LCD digital watch module. Zero danger, pure science!',
      icon: Icons.access_time_filled,
      accentColor: AppColors.categoryElectronics,
      difficultyRank: DifficultyRank.novice,
      estimatedMinutes: 15,
      stepCount: 4,
      xpReward: 150,
      materialsList: const ['4 Lemons', 'Zinc nails', 'Copper coins', 'Wires with clips', 'LCD clock module'],
      minHeroTier: HeroTier.kids,
      lessons: _lessons('electric_lemon_clock', [
        'Prep the Lemons',
        'Insert the Electrodes',
        'Wire the Circuit',
        'Power the Clock',
      ], [
        ['Roll each lemon on a table to loosen the juice inside.', 'Line up 4 lemons in a row.'],
        ['Push a zinc nail into one end of each lemon.', 'Push a copper coin into the other end.'],
        ['Connect copper of one lemon to zinc of the next with a wire.', 'Repeat until all lemons are chained.'],
        ['Attach the final wires to the clock module terminals.', 'Watch the display light up!'],
      ]),
    ),
    SkillModel(
      id: 'mini_solar_bug_bot',
      title: 'Mini Solar Bug Bot',
      category: electronics,
      description:
          'Mount a miniature photovoltaic cell to an eccentric pager motor and paperclip legs. Put it in the sun and watch it scurry!',
      icon: Icons.bug_report,
      accentColor: AppColors.categoryElectronics,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 30,
      stepCount: 6,
      xpReward: 280,
      materialsList: const ['Small solar cell', 'Pager vibration motor', 'Paperclips', 'Hot glue', 'Small board base'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('mini_solar_bug_bot', [
        'Build the Body',
        'Bend the Legs',
        'Mount the Motor',
        'Wire the Solar Cell',
        'Balance the Bot',
        'Test in Sunlight',
      ], [
        ['Cut a small rectangle from the base board.', 'Sand the edges smooth.'],
        ['Bend 6 paperclips into leg shapes.', 'Glue 3 legs to each side of the base.'],
        ['Glue the vibration motor off-center on top of the base.', 'Let the glue fully cure.'],
        ['Solder solar cell leads to the motor terminals.', 'Double-check polarity.'],
        ['Adjust leg angles so the bot stands level.', 'Nudge it to confirm it can tip forward.'],
        ['Place the bot in direct sunlight.', 'Watch the legs vibrate and walk it forward.'],
      ]),
    ),
    SkillModel(
      id: 'diy_sensor_nightlight',
      title: 'DIY Sensor Nightlight',
      category: electronics,
      description:
          'Create an automated bedroom nightlight that springs to life when room lights go out, powered by a simple photoresistor circuit.',
      icon: Icons.lightbulb,
      accentColor: AppColors.categoryElectronics,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 45,
      stepCount: 5,
      xpReward: 320,
      materialsList: const ['LDR photoresistor', 'LED', 'Transistor', 'Resistors', '9V battery + clip'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('diy_sensor_nightlight', [
        'Understand the Circuit',
        'Breadboard the Sensor',
        'Add the LED Driver',
        'Solder to Perfboard',
        'Mount and Calibrate',
      ], [
        ['Learn how a photoresistor changes resistance with light.', 'Sketch the circuit diagram.'],
        ['Place the LDR and resistor in a voltage divider.', 'Connect to the transistor base.'],
        ['Wire the LED and current-limiting resistor to the transistor.', 'Test with a flashlight.'],
        ['Transfer the working breadboard circuit to perfboard.', 'Solder all connections.'],
        ['Mount the finished circuit in a small enclosure.', 'Adjust the resistor value for your room\'s darkness level.'],
      ]),
    ),
    SkillModel(
      id: 'wireless_bt_boombox',
      title: 'Wireless Bluetooth Boombox',
      category: electronics,
      description:
          'Wire a 2x3W amplifier chip to recycled computer speakers and stream high-octane tunes from your phone.',
      icon: Icons.speaker,
      accentColor: AppColors.categoryElectronics,
      difficultyRank: DifficultyRank.master,
      estimatedMinutes: 90,
      stepCount: 8,
      xpReward: 600,
      materialsList: const ['Bluetooth audio module', '2x3W amp board', 'Recycled speakers', '18650 batteries', 'Enclosure box'],
      minHeroTier: HeroTier.adult,
      lessons: _lessons('wireless_bt_boombox', [
        'Plan the Layout',
        'Prep the Speakers',
        'Wire the Amp Board',
        'Connect Bluetooth Module',
        'Wire the Battery Pack',
        'Add Power Switch',
        'Mount Everything',
        'Test and Tune',
      ], [
        ['Sketch where each component will sit in the enclosure.', 'Mark mounting holes.'],
        ['Desolder speakers from their original housing.', 'Test each speaker with a multimeter.'],
        ['Solder speaker leads to the amp board outputs.', 'Connect amp input to the Bluetooth module.'],
        ['Wire the Bluetooth module\'s power pins to the battery line.', 'Pair it with a phone to test audio.'],
        ['Wire batteries in series for correct voltage.', 'Add a fuse for safety.'],
        ['Install a power switch between battery and amp.', 'Test on/off function.'],
        ['Mount all components into the enclosure.', 'Secure with hot glue or screws.'],
        ['Play music and adjust volume/gain trim pots.', 'Check for rattles or buzzing.'],
      ]),
    ),

    // ── Home Repair ─────────────────────────────────────────────────
    SkillModel(
      id: 'fix_leaky_faucet',
      title: 'Fix a Leaky Faucet',
      category: homeRepair,
      description: 'Stop that drip for good by replacing a worn-out washer or cartridge in a standard faucet.',
      icon: Icons.plumbing,
      accentColor: AppColors.categoryHomeRepair,
      difficultyRank: DifficultyRank.novice,
      estimatedMinutes: 20,
      stepCount: 4,
      xpReward: 120,
      materialsList: const ['Adjustable wrench', 'Replacement washer/cartridge', 'Plumber\'s tape', 'Old towel'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('fix_leaky_faucet', [
        'Shut Off Water Supply',
        'Disassemble the Handle',
        'Replace the Worn Part',
        'Reassemble and Test',
      ], [
        ['Locate the shutoff valve under the sink.', 'Turn it clockwise until fully closed.'],
        ['Remove the decorative cap and handle screw.', 'Lift off the handle to expose the cartridge.'],
        ['Pull out the old washer or cartridge.', 'Insert the new part in the same orientation.'],
        ['Reassemble the handle in reverse order.', 'Turn water back on and check for leaks.'],
      ]),
    ),
    SkillModel(
      id: 'patch_drywall_hole',
      title: 'Patch a Drywall Hole',
      category: homeRepair,
      description: 'Repair small to medium wall holes so they look brand new after a coat of paint.',
      icon: Icons.handyman,
      accentColor: AppColors.categoryHomeRepair,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 35,
      stepCount: 5,
      xpReward: 250,
      materialsList: const ['Drywall patch kit', 'Joint compound', 'Putty knife', 'Sandpaper', 'Paint + brush'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('patch_drywall_hole', [
        'Clean the Hole Edges',
        'Apply the Patch',
        'Spread Joint Compound',
        'Sand it Smooth',
        'Paint to Match',
      ], [
        ['Remove loose debris around the hole.', 'Trim any ragged paper edges.'],
        ['Center the self-adhesive patch over the hole.', 'Press firmly to secure.'],
        ['Spread a thin layer of joint compound over the patch.', 'Let it dry fully (check can for time).'],
        ['Sand the dried compound until flush with the wall.', 'Wipe away dust.'],
        ['Apply primer if needed.', 'Paint to match the surrounding wall.'],
      ]),
    ),

    // ── Woodcraft ───────────────────────────────────────────────────
    SkillModel(
      id: 'simple_bookshelf',
      title: 'Build a Simple Bookshelf',
      category: woodcraft,
      description: 'Construct a sturdy 3-shelf bookcase using basic pine boards and wood screws.',
      icon: Icons.shelves,
      accentColor: AppColors.categoryWoodcraft,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 60,
      stepCount: 6,
      xpReward: 300,
      materialsList: const ['Pine boards', 'Wood screws', 'Drill', 'Wood glue', 'Sandpaper', 'Measuring tape'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('simple_bookshelf', [
        'Measure and Cut Boards',
        'Sand All Surfaces',
        'Build the Side Frames',
        'Attach the Shelves',
        'Add the Back Panel',
        'Sand and Finish',
      ], [
        ['Measure and mark cut lines on each board.', 'Cut to length with a saw.'],
        ['Sand every cut edge and face.', 'Wipe away sawdust.'],
        ['Glue and screw the two side frame boards together.', 'Check the frame is square.'],
        ['Mark shelf positions on the side frames.', 'Screw shelves into place.'],
        ['Cut a thin back panel to size.', 'Nail it to the rear of the frame for rigidity.'],
        ['Do a final sanding pass.', 'Apply stain or paint if desired.'],
      ]),
    ),
    SkillModel(
      id: 'wooden_coaster_set',
      title: 'Carve a Wooden Coaster Set',
      category: woodcraft,
      description: 'Cut and sand a simple set of 4 wooden coasters, perfect for a first woodworking project.',
      icon: Icons.circle,
      accentColor: AppColors.categoryWoodcraft,
      difficultyRank: DifficultyRank.novice,
      estimatedMinutes: 25,
      stepCount: 4,
      xpReward: 150,
      materialsList: const ['Wood scrap plank', 'Round cutting jig or compass', 'Sandpaper', 'Wood sealant'],
      minHeroTier: HeroTier.kids,
      lessons: _lessons('wooden_coaster_set', [
        'Trace the Circles',
        'Cut Out the Coasters',
        'Sand the Edges',
        'Seal the Wood',
      ], [
        ['Use a compass to trace 4 equal circles on the plank.', 'Double-check sizes match.'],
        ['Carefully cut along each traced circle.', 'Ask an adult for help with power tools.'],
        ['Sand rough edges until smooth.', 'Round over the top edge slightly.'],
        ['Apply a food-safe wood sealant.', 'Let dry fully before use.'],
      ]),
    ),

    // ── Cooking Lab ─────────────────────────────────────────────────
    SkillModel(
      id: 'pizza_box_solar_oven',
      title: 'Pizza Box Solar Oven',
      category: cookingLab,
      description: 'Harness sun rays to bake golden campfire s\'mores without fire, using an old pizza box and foil.',
      icon: Icons.wb_sunny,
      accentColor: AppColors.categoryCookingLab,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 40,
      stepCount: 5,
      xpReward: 250,
      materialsList: const ['Pizza box', 'Aluminum foil', 'Plastic wrap', 'Black construction paper', 'Skewer'],
      minHeroTier: HeroTier.kids,
      lessons: _lessons('pizza_box_solar_oven', [
        'Cut the Flap Window',
        'Line with Foil',
        'Seal with Plastic Wrap',
        'Add the Black Liner',
        'Bake in the Sun',
      ], [
        ['Cut a flap in the box lid, leaving one edge attached.', 'Fold the flap up to act as a reflector.'],
        ['Cover the inside of the flap with foil.', 'Smooth out wrinkles for better reflection.'],
        ['Cut a window in the box top under the flap.', 'Tape plastic wrap over the opening to trap heat.'],
        ['Line the bottom of the box with black paper.', 'This helps absorb heat.'],
        ['Place food inside, prop the flap open toward the sun.', 'Use a skewer to hold the flap angle.'],
      ]),
    ),
    SkillModel(
      id: 'no_bake_energy_bites',
      title: 'No-Bake Energy Bites',
      category: cookingLab,
      description: 'Mix up a quick batch of oats, honey, and peanut butter energy bites — no oven required.',
      icon: Icons.cookie,
      accentColor: AppColors.categoryCookingLab,
      difficultyRank: DifficultyRank.novice,
      estimatedMinutes: 15,
      stepCount: 3,
      xpReward: 100,
      materialsList: const ['Rolled oats', 'Peanut butter', 'Honey', 'Mini chocolate chips', 'Mixing bowl'],
      minHeroTier: HeroTier.kids,
      lessons: _lessons('no_bake_energy_bites', [
        'Mix the Ingredients',
        'Roll into Balls',
        'Chill and Serve',
      ], [
        ['Combine oats, peanut butter, and honey in a bowl.', 'Stir in chocolate chips.'],
        ['Scoop small amounts and roll into balls with your hands.', 'Place on a lined tray.'],
        ['Refrigerate for at least 20 minutes.', 'Enjoy your energy bites!'],
      ]),
    ),

    // ── Robotics ────────────────────────────────────────────────────
    SkillModel(
      id: 'cardboard_claw_machine',
      title: 'Cardboard Claw Machine',
      category: robotics,
      description: 'Build a hand-cranked claw machine mechanism using cardboard, string, and simple pulleys.',
      icon: Icons.precision_manufacturing,
      accentColor: AppColors.categoryRobotics,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 50,
      stepCount: 6,
      xpReward: 280,
      materialsList: const ['Cardboard box', 'String', 'Skewers', 'Small pulleys or straws', 'Clothespin claw'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('cardboard_claw_machine', [
        'Build the Frame',
        'Add the Crane Rail',
        'Attach the Claw',
        'Rig the Pulley System',
        'Add the Crank Handle',
        'Test and Adjust',
      ], [
        ['Cut and assemble the box into an open frame.', 'Reinforce corners with tape.'],
        ['Add a horizontal skewer rail across the top.', 'Make sure it can slide smoothly.'],
        ['Build a simple claw from a clothespin.', 'Attach it to a hanging string.'],
        ['Thread string through straws acting as pulleys.', 'Connect to the crank mechanism.'],
        ['Attach a small handle to wind the string.', 'Test that winding raises the claw.'],
        ['Test grabbing small objects.', 'Adjust string tension as needed.'],
      ]),
    ),
    SkillModel(
      id: 'solar_mini_rover',
      title: 'Solar Mini Rover',
      category: robotics,
      description:
          'Harness raw photon energy to drive your very own miniature rover vehicle across rough terrain! Zero soldering required.',
      icon: Icons.directions_car,
      accentColor: AppColors.categoryRobotics,
      difficultyRank: DifficultyRank.master,
      estimatedMinutes: 35,
      stepCount: 4,
      xpReward: 300,
      materialsList: const [
        'Mini 5V Solar Cell Panel',
        'High-Torque Micro DC Motor',
        'Lightweight Balsa Chassis & Axles',
        'Hot Glue or Safety Tape',
      ],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('solar_mini_rover', [
        'Chassis Blueprint & Axle Assembly',
        'Mounting the Electric Motor Gear',
        'Wiring Solar Power Leads (No Solder!)',
        'Test Run in Direct Sunlight!',
      ], [
        ['Measure and space the balsa axles evenly.', 'Glue wheels onto each axle.'],
        ['Align the drive gear with the rear axle.', 'Secure the motor mount with tape or glue.'],
        ['Twist-cap pair the solar panel leads to the motor.', 'Double check polarity before testing.'],
        ['Angle the solar panel at 45 degrees toward the sun.', 'Place the rover on a flat surface and watch it roll.'],
      ]),
    ),

    // ── Gardening & Eco ─────────────────────────────────────────────
    SkillModel(
      id: 'mini_herb_garden',
      title: 'Grow a Mini Herb Garden',
      category: gardening,
      description: 'Start a small windowsill herb garden with basil, mint, and parsley from seed.',
      icon: Icons.eco,
      accentColor: AppColors.categoryGardening,
      difficultyRank: DifficultyRank.novice,
      estimatedMinutes: 20,
      stepCount: 3,
      xpReward: 120,
      materialsList: const ['Small pots', 'Potting soil', 'Herb seeds', 'Watering can'],
      minHeroTier: HeroTier.kids,
      lessons: _lessons('mini_herb_garden', [
        'Fill the Pots',
        'Plant the Seeds',
        'Water and Wait',
      ], [
        ['Fill each pot with potting soil, leaving space at the top.', 'Pat down gently.'],
        ['Follow the seed packet for planting depth.', 'Cover seeds lightly with soil.'],
        ['Water lightly every day.', 'Place pots near a sunny window and watch them sprout.'],
      ]),
    ),
    SkillModel(
      id: 'build_compost_bin',
      title: 'Build a Compost Bin',
      category: gardening,
      description: 'Turn kitchen scraps into rich garden soil with a simple DIY compost bin.',
      icon: Icons.recycling,
      accentColor: AppColors.categoryGardening,
      difficultyRank: DifficultyRank.cadet,
      estimatedMinutes: 45,
      stepCount: 5,
      xpReward: 260,
      materialsList: const ['Plastic storage bin', 'Drill', 'Shredded newspaper', 'Soil', 'Kitchen scraps'],
      minHeroTier: HeroTier.teens,
      lessons: _lessons('build_compost_bin', [
        'Drill Ventilation Holes',
        'Add a Base Layer',
        'Layer in Scraps',
        'Balance Greens and Browns',
        'Maintain the Pile',
      ], [
        ['Drill small holes around the sides and lid.', 'This lets air circulate.'],
        ['Add a layer of shredded newspaper on the bottom.', 'Add a thin layer of soil on top.'],
        ['Add fruit and vegetable scraps.', 'Avoid meat and dairy.'],
        ['Balance "green" scraps with "brown" materials like dry leaves.', 'Keep roughly equal parts.'],
        ['Stir the pile weekly with a stick.', 'Keep it slightly damp, not soggy.'],
      ]),
    ),
  ];

  static List<SkillModel> byCategory(String category) {
    return all.where((s) => s.category == category).toList();
  }
}