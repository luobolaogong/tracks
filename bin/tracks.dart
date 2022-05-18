import 'dart:io';
import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
import 'commandline.dart';
///
/// Tracks takes tracks from 2 or more input midi files and puts them into an output midi file.
/// The purpose is to merge drum tracks with bagpipe tracks, since I've been unable to handle
/// both SnareLang and PipeLang input files at the same time, due to wonderful PetitParser's
/// lack of documentation as to how to dynamicly switch parsers.
///
/// For each input midi file you can specify which tracks to use.  I don't think order matters.
///
/// It would be nice if I could pan the tracks in the new file so make it more stereo.  This
/// does not seem possible from the API.  Looks like need to create a sound font file with
/// different pans and different pitches for same thing.  Maybe 3 to 5 snares.
///
/// The Dart Midi API is at https://pub.dev/documentation/dart_midi/latest/midi/midi-library.html
///
///
void main(List<String> arguments) {
  final ticksPerBeat = 10080;
  final microsecondsPerMinute = 60000000;

  print('Staring tracks ...');
  Logger.root.level = Level.ALL; // get this from the command line, as a secret setting
  Logger.root.onRecord.listen((record) {
    print('$record'); // wow!!!  I can change how it prints!
  });
  final log = Logger('Tracks');

  var commandLine = CommandLine();
  var argResults = commandLine.parseCommandLineArgs(arguments);

  var parser = MidiParser();

  // Check input files and exit early if not right
  for (var filePath in commandLine.inputFilesList) {
    log.info('Loading file $filePath');
    var inputFile = File(filePath);
    if (!inputFile.existsSync()) {
      log.severe('File does not exist at "${inputFile.path}", exiting...');
      exit(42);
      continue;
    }
    var parsedMidi = parser.parseMidiFromFile(inputFile);
    //print(parsedMidi.tracks.length);
    //print(parsedMidi.header.numTracks);
    if (parsedMidi.header.numTracks <= 0) {
      log.info('File ${filePath} appears to be empty.  Skipping it. (prob should exit)');
      continue;
    }
  }

  var midiHeader = MidiHeader(ticksPerBeat: ticksPerBeat, format:1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?
  var midiTracks = <List<MidiEvent>>[];

  for (var inputFilePath in commandLine.inputFilesList) {
    var inputFile = File(inputFilePath);
    var parsedMidi = parser.parseMidiFromFile(inputFile);
    for (var track in parsedMidi.tracks) {
      midiTracks.add(track);
    }
  }

  var midiFile = MidiFile(midiTracks, midiHeader);
  var midiWriterCopy = MidiWriter();

  var midiFileOutFile = File(commandLine.outputMidiFile);
  midiWriterCopy.writeMidiToFile(midiFile, midiFileOutFile);

  print('Done writing midifile ${midiFileOutFile.path}');
}

