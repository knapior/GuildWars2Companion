import 'package:guildwars2_companion/features/build/models/skill_trait.dart';
import 'package:guildwars2_companion/features/build/models/specialization.dart';

class Build {
  String name;
  String profession;
  List<BuildSpecialization> specializations;
  BuildSkillset skills;
  BuildSkillset aquaticSkills;

  Build(
      {this.name,
      this.profession,
      this.specializations,
      this.skills,
      this.aquaticSkills});

  Build.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profession = json['profession'];
    if (json['specializations'] != null) {
      specializations = (json['specializations'] as List)
        .map((j) => BuildSpecialization.fromJson(j))
        .toList();
    }
    skills =
        json['skills'] != null ? new BuildSkillset.fromJson(json['skills']) : null;
    aquaticSkills = json['aquatic_skills'] != null
        ? new BuildSkillset.fromJson(json['aquatic_skills'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['profession'] = this.profession;
    if (this.specializations != null) {
      data['specializations'] =
          this.specializations.map((v) => v.toJson()).toList();
    }
    if (this.skills != null) {
      data['skills'] = this.skills.toJson();
    }
    if (this.aquaticSkills != null) {
      data['aquatic_skills'] = this.aquaticSkills.toJson();
    }
    return data;
  }
}

class BuildSpecialization {
  int id;
  List<int> traits;

  Specialization specializationDetails;

  BuildSpecialization({this.id, this.traits});

  BuildSpecialization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    traits = json['traits'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['traits'] = this.traits;
    return data;
  }
}

class BuildSkillset {
  int heal;
  List<int> utilities;
  int elite;

  SkillTrait healDetails;
  List<SkillTrait> utilityDetails;
  SkillTrait eliteDetails;

  BuildSkillset({this.heal, this.utilities, this.elite});

  BuildSkillset.fromJson(Map<String, dynamic> json) {
    heal = json['heal'];
    utilities = json['utilities'].cast<int>();
    elite = json['elite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['heal'] = this.heal;
    data['utilities'] = this.utilities;
    data['elite'] = this.elite;
    return data;
  }
}