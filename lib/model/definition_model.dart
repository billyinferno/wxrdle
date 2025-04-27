// To parse this JSON data, do
//
//     final definitionModel = definitionModelFromJson(jsonString);

import 'dart:convert';

DefinitionModel definitionModelFromJson(String str) => DefinitionModel.fromJson(json.decode(str));

String definitionModelToJson(DefinitionModel data) => json.encode(data.toJson());

class DefinitionModel {
    final int status;
    final List<dynamic> errors;
    final List<Datum> data;

    DefinitionModel({
        required this.status,
        required this.errors,
        required this.data,
    });

    factory DefinitionModel.fromJson(Map<String, dynamic> json) => DefinitionModel(
        status: json["status"],
        errors: List<dynamic>.from(json["errors"].map((x) => x)),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "errors": List<dynamic>.from(errors.map((x) => x)),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    final String slug;
    final String headword;
    final String audio;
    final List<Po> pos;

    Datum({
        required this.slug,
        required this.headword,
        required this.audio,
        required this.pos,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        slug: json["slug"],
        headword: json["headword"],
        audio: json["audio"],
        pos: List<Po>.from(json["pos"].map((x) => Po.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "slug": slug,
        "headword": headword,
        "audio": audio,
        "pos": List<dynamic>.from(pos.map((x) => x.toJson())),
    };
}

class Po {
    final String poPart;
    final List<Sense> senses;

    Po({
        required this.poPart,
        required this.senses,
    });

    factory Po.fromJson(Map<String, dynamic> json) => Po(
        poPart: (json["part"] ?? ''),
        senses: List<Sense>.from(json["senses"].map((x) => Sense.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "part": poPart,
        "senses": List<dynamic>.from(senses.map((x) => x.toJson())),
    };
}

class Sense {
    final List<Subsense> subsenses;
    final String? txt;

    Sense({
        required this.subsenses,
        this.txt,
    });

    factory Sense.fromJson(Map<String, dynamic> json) => Sense(
        subsenses: List<Subsense>.from(json["subsenses"].map((x) => Subsense.fromJson(x))),
        txt: json["txt"],
    );

    Map<String, dynamic> toJson() => {
        "subsenses": List<dynamic>.from(subsenses.map((x) => x.toJson())),
        "txt": txt,
    };
}

class Subsense {
    final String txt;

    Subsense({
        required this.txt,
    });

    factory Subsense.fromJson(Map<String, dynamic> json) => Subsense(
        txt: json["txt"],
    );

    Map<String, dynamic> toJson() => {
        "txt": txt,
    };
}
