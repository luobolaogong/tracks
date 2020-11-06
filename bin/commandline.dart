import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';

class CommandLine {
  ArgParser argParser;
  ArgResults argResults;

  List<String> _inputFilesList;
  String _outputMidiFile;

  static final helpMapIndex = 'help'; // -h
  static final logLevelMapIndex = 'log'; // -l
  static final inputFileListMapIndex = 'input'; // -i  --input
  static final outputMidiFilePathMapIndex = 'midiout'; // -o --output  --outmidi

  List<String> get inputFilesList {
    return _inputFilesList;
  }
  String get outputMidiFile {
    return _outputMidiFile;
  }

  ArgResults parseCommandLineArgs(List<String> arguments) {
    var parser = CommandLine.createCommandLineParser();
    try {
      argResults = parser.parse(arguments);
    }
    catch (exception) {
      print('Usage:\n${parser.usage}');
      print('${exception}  Exiting...');
      exitCode = 42; // "Process finished with exit code 43"  What's the benefit?
      //return;
      exit(exitCode);
    }

    if (argResults.arguments.isEmpty) {
      print('No arguments provided.  Aborting ...');
      print('Usage:\n${parser.usage}');
      print(
          'Example: <thisProg> -p Tunes/BadgeOfScotland.ppl,Tunes/RowanTree.ppl,Tunes/ScotlandTheBravePipes.ppl --midi midifiles/BadgeSet.mid');
      exitCode = 2; // does anything?
      //return;
      exit(exitCode);
    }
    if (argResults.rest.isNotEmpty) {
      print('Ignoring command line arguments: -->${argResults.rest}<-- and aborting ...');
      print('Usage:\n${parser.usage}');
      print(
          'Example: <thisProg> -p Tunes/BadgeOfScotland.ppl,Tunes/RowanTree.ppl,Tunes/ScotlandTheBravePipes.ppl --midi midifiles/BadgeSet.mid');
      exitCode = 2; // does anything?
      // return;
      exit(exitCode);
    }

    if (argResults[helpMapIndex]) {
      print('Usage:\n${parser.usage}');
      //return;
      exitCode = 0;
      exit(exitCode);
    }
    //print('track thing: ${argResults['track']}'); // this prints out whatever is the default value in the parser creator

    // Set the log level.  Guess this is special and should do it first.
    if (argResults[logLevelMapIndex] != null) {
      switch (argResults[logLevelMapIndex]) {
        case 'ALL':
          Logger.root.level = Level.ALL;
          break;
        case 'FINEST':
          Logger.root.level = Level.FINEST;
          break;
        case 'FINER':
          Logger.root.level = Level.FINER;
          break;
        case 'FINE':
          Logger.root.level = Level.FINE;
          break;
        case 'CONFIG':
          Logger.root.level = Level.CONFIG;
          break;
        case 'INFO':
          Logger.root.level = Level.INFO;
          break;
        case 'WARNING':
          Logger.root.level = Level.WARNING;
          break;
        case 'SEVERE':
          Logger.root.level = Level.SEVERE;
          break;
        case 'SHOUT':
          Logger.root.level = Level.SHOUT;
          break;
        case 'OFF':
          Logger.root.level = Level.OFF;
          break;
        default:
          Logger.root.level = Level.OFF;
      }
    }
    storeTheResultValues(); // Track constructor not yet called until get into this method
    return argResults;
  }

  void storeTheResultValues() {
    if (argResults[CommandLine.inputFileListMapIndex] != null) { // not sure
      _inputFilesList = [...argResults[CommandLine.inputFileListMapIndex]];
    }
    if (argResults[CommandLine.outputMidiFilePathMapIndex] != null) {
      _outputMidiFile = argResults[CommandLine.outputMidiFilePathMapIndex];
    }
  }

  static ArgParser createCommandLineParser() {
    var now = DateTime.now();
    // If no midi file given, but 1 input file given, name it same with .midi
    var timeStampedMidiOutCurDirName =
        'Tune${now.year}${now.month}${now.day}${now.hour}${now.minute}.mid';

    // Define/create the parser so you can use it later.
    var argParser = ArgParser()
      ..addMultiOption(CommandLine.inputFileListMapIndex,
          abbr: 'i',
          help:
          'List of input files/pieces, \nseparated by commas, without spaces.',
          valueHelp: 'path1,path2,...')

      ..addOption(CommandLine.outputMidiFilePathMapIndex,
          abbr: 'o',
          defaultsTo: timeStampedMidiOutCurDirName,
          help:
          'This is the output midi file name and path.  \neg: tunes/TheBrave.mid   Running now would generate "Tune<dateAndTime>.midi"',
          valueHelp: 'path')

      ..addOption(CommandLine.logLevelMapIndex,
          hide: true,
          abbr: 'l',
          allowed: ['ALL', 'FINEST', 'FINER', 'FINE', 'CONFIG', 'INFO', 'WARNING', 'SEVERE', 'SHOUT', 'OFF'],
          defaultsTo: 'OFF',
          help:
          'Set the log level.  This is a hidden optionl',
          valueHelp: 'WARNING')

      ..addFlag(CommandLine.helpMapIndex,
          abbr: 'h',
          negatable: false,
          help:
          'help by showing usage then exiting');

    return argParser;
  }
}