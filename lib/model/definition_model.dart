// To parse this JSON data, do
//
//     final definitionModel = definitionModelFromJson(jsonString);

import 'dart:convert';

DefinitionModel definitionModelFromJson(String str) => DefinitionModel.fromJson(json.decode(str));

String definitionModelToJson(DefinitionModel data) => json.encode(data.toJson());

class DefinitionModel {
    DefinitionModel({
        required this.status,
        required this.errors,
        required this.data,
    });

    final int status;
    final List<Error> errors;
    final List<Datum> data;

    factory DefinitionModel.fromJson(Map<String, dynamic> json) => DefinitionModel(
        status: json["status"],
        errors: List<Error>.from(json["errors"].map((x) => Error.fromJson(x))),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        required this.slug,
        required this.headword,
        this.audio,
        required this.syllables,
        required this.pos,
    });

    final String slug;
    final String headword;
    final String? audio;
    final String syllables;
    final List<Po> pos;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        slug: json["slug"],
        headword: json["headword"],
        audio: (json["audio"]),
        syllables: json["syllables"],
        pos: List<Po>.from(json["pos"].map((x) => Po.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "slug": slug,
        "headword": headword,
        "syllables": syllables,
        "pos": List<dynamic>.from(pos.map((x) => x.toJson())),
    };
}

class Po {
    Po({
        required this.poPart,
        required this.senses,
    });

    final String poPart;
    final List<Sense> senses;

    factory Po.fromJson(Map<String, dynamic> json) => Po(
        poPart: json["part"],
        senses: List<Sense>.from(json["senses"].map((x) => Sense.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "part": poPart,
        "senses": List<dynamic>.from(senses.map((x) => x.toJson())),
    };
}

class Sense {
    Sense({
        required this.txt,
        required this.subsenses,
    });

    final String txt;
    final List<dynamic> subsenses;

    factory Sense.fromJson(Map<String, dynamic> json) => Sense(
        txt: json["txt"],
        subsenses: List<dynamic>.from(json["subsenses"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "txt": txt,
        "subsenses": List<dynamic>.from(subsenses.map((x) => x)),
    };
}

class Error {
    Error({
        required this.code,
        required this.message,
    });

    final String code;
    final String message;

    factory Error.fromJson(Map<String, dynamic> json) => Error(
        code: json["code"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
    };
}
