// lib/constants/category_style.dart
// Presentation helpers for the 6 labs (categories): color, short label,
// icon and the one-line blurb shown on tiles. Keyed by the category names
// in SkillsData, so screens never hardcode category strings.

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'skills_data.dart';

class CategoryStyle {
  CategoryStyle._();

  /// Flat fill color for a category.
  static Color color(String category) {
    switch (category) {
      case SkillsData.electronics:
        return AppColors.categoryElectronics;
      case SkillsData.homeRepair:
        return AppColors.categoryHomeRepair;
      case SkillsData.woodcraft:
        return AppColors.categoryWoodcraft;
      case SkillsData.cookingLab:
        return AppColors.categoryCookingLab;
      case SkillsData.robotics:
        return AppColors.categoryRobotics;
      case SkillsData.gardening:
        return AppColors.categoryGardening;
      default:
        return AppColors.locked;
    }
  }

  /// Short name for captions and tags ("Electronics • 4 Episodes").
  static String shortLabel(String category) {
    switch (category) {
      case SkillsData.electronics:
        return 'Electronics';
      case SkillsData.homeRepair:
        return 'Home Repair';
      case SkillsData.woodcraft:
        return 'Woodcraft';
      case SkillsData.cookingLab:
        return 'Cooking Lab';
      case SkillsData.robotics:
        return 'Robotics';
      case SkillsData.gardening:
        return 'Gardening';
      default:
        return category;
    }
  }

  static IconData icon(String category) {
    switch (category) {
      case SkillsData.electronics:
        return Icons.memory;
      case SkillsData.homeRepair:
        return Icons.build;
      case SkillsData.woodcraft:
        return Icons.carpenter;
      case SkillsData.cookingLab:
        return Icons.restaurant;
      case SkillsData.robotics:
        return Icons.smart_toy;
      case SkillsData.gardening:
        return Icons.eco;
      default:
        return Icons.category;
    }
  }

  /// One-line description for category tiles and headers.
  static String blurb(String category) {
    switch (category) {
      case SkillsData.electronics:
        return 'Circuits, sensors, soldering and audio gadgets.';
      case SkillsData.homeRepair:
        return 'Practical fixes, plumbing and drywall mastery.';
      case SkillsData.woodcraft:
        return 'Joinery, carving, shelving and timber craft.';
      case SkillsData.cookingLab:
        return 'Solar ovens, energy fuel and culinary science.';
      case SkillsData.robotics:
        return 'Mechanisms, automated rovers and claw machines.';
      case SkillsData.gardening:
        return 'Hydroponics, composting and solar biology.';
      default:
        return '';
    }
  }
}
