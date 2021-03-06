// This code was auto-generated, is not intended to be edited, and is subject to
// significant change. Please see the README file for more information.

library engine.sdk.io;

import 'dart:io';
import 'dart:uri';
import 'java_core.dart';
import 'java_io.dart';
import 'java_engine.dart';
import 'java_engine_io.dart';
import 'source_io.dart';
import 'error.dart';
import 'scanner.dart';
import 'ast.dart';
import 'parser.dart';
import 'sdk.dart';
import 'engine.dart';

/**
 * Instances of the class {@code DirectoryBasedDartSdk} represent a Dart SDK installed in a
 * specified directory.
 * @coverage dart.engine.sdk
 */
class DirectoryBasedDartSdk implements DartSdk {
  /**
   * The {@link AnalysisContext} which is used for all of the sources in this {@link DartSdk}.
   */
  InternalAnalysisContext _analysisContext;
  /**
   * The directory containing the SDK.
   */
  JavaFile _sdkDirectory;
  /**
   * The revision number of this SDK, or {@code "0"} if the revision number cannot be discovered.
   */
  String _sdkVersion;
  /**
   * The file containing the Dartium executable.
   */
  JavaFile _dartiumExecutable;
  /**
   * The file containing the VM executable.
   */
  JavaFile _vmExecutable;
  /**
   * A mapping from Dart library URI's to the library represented by that URI.
   */
  LibraryMap _libraryMap;
  /**
   * The name of the directory within the SDK directory that contains executables.
   */
  static String _BIN_DIRECTORY_NAME = "bin";
  /**
   * The name of the directory within the SDK directory that contains Chromium.
   */
  static String _CHROMIUM_DIRECTORY_NAME = "chromium";
  /**
   * The name of the environment variable whose value is the path to the default Dart SDK directory.
   */
  static String _DART_SDK_ENVIRONMENT_VARIABLE_NAME = "DART_SDK";
  /**
   * The name of the file containing the Dartium executable on Linux.
   */
  static String _DARTIUM_EXECUTABLE_NAME_LINUX = "chrome";
  /**
   * The name of the file containing the Dartium executable on Macintosh.
   */
  static String _DARTIUM_EXECUTABLE_NAME_MAC = "Chromium.app/Contents/MacOS/Chromium";
  /**
   * The name of the file containing the Dartium executable on Windows.
   */
  static String _DARTIUM_EXECUTABLE_NAME_WIN = "Chrome.exe";
  /**
   * The name of the {@link System} property whose value is the path to the default Dart SDK
   * directory.
   */
  static String _DEFAULT_DIRECTORY_PROPERTY_NAME = "com.google.dart.sdk";
  /**
   * The version number that is returned when the real version number could not be determined.
   */
  static String _DEFAULT_VERSION = "0";
  /**
   * The name of the directory within the SDK directory that contains documentation for the
   * libraries.
   */
  static String _DOCS_DIRECTORY_NAME = "docs";
  /**
   * The suffix added to the name of a library to derive the name of the file containing the
   * documentation for that library.
   */
  static String _DOC_FILE_SUFFIX = "_api.json";
  /**
   * The name of the directory within the SDK directory that contains the libraries file.
   */
  static String _INTERNAL_DIR = "_internal";
  /**
   * The name of the directory within the SDK directory that contains the libraries.
   */
  static String _LIB_DIRECTORY_NAME = "lib";
  /**
   * The name of the libraries file.
   */
  static String _LIBRARIES_FILE = "libraries.dart";
  /**
   * The name of the file within the SDK directory that contains the revision number of the SDK.
   */
  static String _REVISION_FILE_NAME = "revision";
  /**
   * The name of the file containing the VM executable on the Windows operating system.
   */
  static String _VM_EXECUTABLE_NAME_WIN = "dart.exe";
  /**
   * The name of the file containing the VM executable on non-Windows operating systems.
   */
  static String _VM_EXECUTABLE_NAME = "dart";
  /**
   * Return the default Dart SDK, or {@code null} if the directory containing the default SDK cannot
   * be determined (or does not exist).
   * @return the default Dart SDK
   */
  static DirectoryBasedDartSdk get defaultSdk {
    JavaFile sdkDirectory = defaultSdkDirectory;
    if (sdkDirectory == null) {
      return null;
    }
    return new DirectoryBasedDartSdk(sdkDirectory);
  }
  /**
   * Return the default directory for the Dart SDK, or {@code null} if the directory cannot be
   * determined (or does not exist). The default directory is provided by a {@link System} property
   * named {@code com.google.dart.sdk}, or, if the property is not defined, an environment variable
   * named {@code DART_SDK}.
   * @return the default directory for the Dart SDK
   */
  static JavaFile get defaultSdkDirectory {
    String sdkProperty = JavaSystemIO.getProperty(_DEFAULT_DIRECTORY_PROPERTY_NAME);
    if (sdkProperty == null) {
      sdkProperty = JavaSystemIO.getenv(_DART_SDK_ENVIRONMENT_VARIABLE_NAME);
      if (sdkProperty == null) {
        return null;
      }
    }
    JavaFile sdkDirectory = new JavaFile(sdkProperty);
    if (!sdkDirectory.exists()) {
      return null;
    }
    return sdkDirectory;
  }
  /**
   * Initialize a newly created SDK to represent the Dart SDK installed in the given directory.
   * @param sdkDirectory the directory containing the SDK
   */
  DirectoryBasedDartSdk(JavaFile sdkDirectory) {
    this._sdkDirectory = sdkDirectory.getAbsoluteFile();
    initializeSdk();
    initializeLibraryMap();
    _analysisContext = new AnalysisContextImpl();
    _analysisContext.sourceFactory = new SourceFactory.con2([new DartUriResolver(this)]);
    List<String> uris2 = uris;
    ChangeSet changeSet = new ChangeSet();
    for (String uri in uris2) {
      changeSet.added(_analysisContext.sourceFactory.forUri(uri));
    }
    _analysisContext.applyChanges(changeSet);
  }
  Source fromEncoding(ContentCache contentCache, UriKind kind, Uri uri) => new FileBasedSource.con2(contentCache, new JavaFile.fromUri(uri), kind);
  AnalysisContext get context => _analysisContext;
  /**
   * Return the file containing the Dartium executable, or {@code null} if it does not exist.
   * @return the file containing the Dartium executable
   */
  JavaFile get dartiumExecutable {
    {
      if (_dartiumExecutable == null) {
        JavaFile file = new JavaFile.relative(dartiumWorkingDirectory, dartiumBinaryName);
        if (file.exists()) {
          _dartiumExecutable = file;
        }
      }
    }
    return _dartiumExecutable;
  }
  /**
   * Return the directory where dartium can be found in the Dart SDK (the directory that will be the
   * working directory is Dartium is invoked without changing the default).
   * @return the directory where dartium can be found
   */
  JavaFile get dartiumWorkingDirectory => new JavaFile.relative(_sdkDirectory.getParentFile(), _CHROMIUM_DIRECTORY_NAME);
  /**
   * Return the directory containing the SDK.
   * @return the directory containing the SDK
   */
  JavaFile get directory => _sdkDirectory;
  /**
   * Return the directory containing documentation for the SDK.
   * @return the SDK's documentation directory
   */
  JavaFile get docDirectory => new JavaFile.relative(_sdkDirectory, _DOCS_DIRECTORY_NAME);
  /**
   * Return the auxiliary documentation file for the given library, or {@code null} if no such file
   * exists.
   * @param libraryName the name of the library associated with the documentation file to be
   * returned
   * @return the auxiliary documentation file for the library
   */
  JavaFile getDocFileFor(String libraryName) {
    JavaFile dir = docDirectory;
    if (!dir.exists()) {
      return null;
    }
    JavaFile libDir = new JavaFile.relative(dir, libraryName);
    JavaFile docFile = new JavaFile.relative(libDir, "${libraryName}${_DOC_FILE_SUFFIX}");
    if (docFile.exists()) {
      return docFile;
    }
    return null;
  }
  /**
   * Return the directory within the SDK directory that contains the libraries.
   * @return the directory that contains the libraries
   */
  JavaFile get libraryDirectory => new JavaFile.relative(_sdkDirectory, _LIB_DIRECTORY_NAME);
  List<SdkLibrary> get sdkLibraries => _libraryMap.sdkLibraries;
  /**
   * Return the revision number of this SDK, or {@code "0"} if the revision number cannot be
   * discovered.
   * @return the revision number of this SDK
   */
  String get sdkVersion {
    {
      if (_sdkVersion == null) {
        _sdkVersion = _DEFAULT_VERSION;
        JavaFile revisionFile = new JavaFile.relative(_sdkDirectory, _REVISION_FILE_NAME);
        try {
          String revision = revisionFile.readAsStringSync();
          if (revision != null) {
            _sdkVersion = revision;
          }
        } on IOException catch (exception) {
        }
      }
    }
    return _sdkVersion;
  }
  /**
   * Return an array containing the library URI's for the libraries defined in this SDK.
   * @return the library URI's for the libraries defined in this SDK
   */
  List<String> get uris => _libraryMap.uris;
  /**
   * Return the file containing the VM executable, or {@code null} if it does not exist.
   * @return the file containing the VM executable
   */
  JavaFile get vmExecutable {
    {
      if (_vmExecutable == null) {
        JavaFile file = new JavaFile.relative(new JavaFile.relative(_sdkDirectory, _BIN_DIRECTORY_NAME), binaryName);
        if (file.exists()) {
          _vmExecutable = file;
        }
      }
    }
    return _vmExecutable;
  }
  /**
   * Return {@code true} if this SDK includes documentation.
   * @return {@code true} if this installation of the SDK has documentation
   */
  bool hasDocumentation() => docDirectory.exists();
  /**
   * Return {@code true} if the Dartium binary is available.
   * @return {@code true} if the Dartium binary is available
   */
  bool isDartiumInstalled() => dartiumExecutable != null;
  Source mapDartUri(ContentCache contentCache, String dartUri) {
    SdkLibrary library = _libraryMap.getLibrary(dartUri);
    if (library == null) {
      return null;
    }
    return new FileBasedSource.con2(contentCache, new JavaFile.relative(libraryDirectory, library.path), UriKind.DART_URI);
  }
  /**
   * Ensure that the dart VM is executable. If it is not, make it executable and log that it was
   * necessary for us to do so.
   */
  void ensureVmIsExecutable() {
  }
  /**
   * Return the name of the file containing the VM executable.
   * @return the name of the file containing the VM executable
   */
  String get binaryName {
    if (OSUtilities.isWindows()) {
      return _VM_EXECUTABLE_NAME_WIN;
    } else {
      return _VM_EXECUTABLE_NAME;
    }
  }
  /**
   * Return the name of the file containing the Dartium executable.
   * @return the name of the file containing the Dartium executable
   */
  String get dartiumBinaryName {
    if (OSUtilities.isWindows()) {
      return _DARTIUM_EXECUTABLE_NAME_WIN;
    } else if (OSUtilities.isMac()) {
      return _DARTIUM_EXECUTABLE_NAME_MAC;
    } else {
      return _DARTIUM_EXECUTABLE_NAME_LINUX;
    }
  }
  /**
   * Read all of the configuration files to initialize the library maps.
   */
  void initializeLibraryMap() {
    try {
      JavaFile librariesFile = new JavaFile.relative(new JavaFile.relative(libraryDirectory, _INTERNAL_DIR), _LIBRARIES_FILE);
      String contents = librariesFile.readAsStringSync();
      _libraryMap = new SdkLibrariesReader().readFrom(librariesFile, contents);
    } catch (exception) {
      AnalysisEngine.instance.logger.logError3(exception);
      _libraryMap = new LibraryMap();
    }
  }
  /**
   * Initialize the state of the SDK.
   */
  void initializeSdk() {
    if (!OSUtilities.isWindows()) {
      ensureVmIsExecutable();
    }
  }
}
/**
 * Instances of the class {@code SdkLibrariesReader} read and parse the libraries file
 * (dart-sdk/lib/_internal/libraries.dart) for information about the libraries in an SDK. The
 * library information is represented as a Dart file containing a single top-level variable whose
 * value is a const map. The keys of the map are the names of libraries defined in the SDK and the
 * values in the map are info objects defining the library. For example, a subset of a typical SDK
 * might have a libraries file that looks like the following:
 * <pre>
 * final Map&lt;String, LibraryInfo&gt; LIBRARIES = const &lt;LibraryInfo&gt; {
 * // Used by VM applications
 * "builtin" : const LibraryInfo(
 * "builtin/builtin_runtime.dart",
 * category: "Server",
 * platforms: VM_PLATFORM),
 * "compiler" : const LibraryInfo(
 * "compiler/compiler.dart",
 * category: "Tools",
 * platforms: 0),
 * };
 * </pre>
 * @coverage dart.engine.sdk
 */
class SdkLibrariesReader {
  /**
   * Return the library map read from the given source.
   * @return the library map read from the given source
   */
  LibraryMap readFrom(JavaFile librariesFile, String libraryFileContents) {
    List<bool> foundError = [false];
    AnalysisErrorListener errorListener = new AnalysisErrorListener_10(foundError);
    Source source = new FileBasedSource.con2(null, librariesFile, UriKind.FILE_URI);
    StringScanner scanner = new StringScanner(source, libraryFileContents, errorListener);
    Parser parser = new Parser(source, errorListener);
    CompilationUnit unit = parser.parseCompilationUnit(scanner.tokenize());
    SdkLibrariesReader_LibraryBuilder libraryBuilder = new SdkLibrariesReader_LibraryBuilder();
    if (!foundError[0]) {
      unit.accept(libraryBuilder);
    }
    return libraryBuilder.librariesMap;
  }
}
class SdkLibrariesReader_LibraryBuilder extends RecursiveASTVisitor<Object> {
  /**
   * The prefix added to the name of a library to form the URI used in code to reference the
   * library.
   */
  static String _LIBRARY_PREFIX = "dart:";
  /**
   * The name of the optional parameter used to indicate whether the library is an implementation
   * library.
   */
  static String _IMPLEMENTATION = "implementation";
  /**
   * The name of the optional parameter used to indicate whether the library is documented.
   */
  static String _DOCUMENTED = "documented";
  /**
   * The name of the optional parameter used to specify the category of the library.
   */
  static String _CATEGORY = "category";
  /**
   * The name of the optional parameter used to specify the platforms on which the library can be
   * used.
   */
  static String _PLATFORMS = "platforms";
  /**
   * The value of the {@link #PLATFORMS platforms} parameter used to specify that the library can
   * be used on the VM.
   */
  static String _VM_PLATFORM = "VM_PLATFORM";
  /**
   * The library map that is populated by visiting the AST structure parsed from the contents of
   * the libraries file.
   */
  LibraryMap _librariesMap = new LibraryMap();
  /**
   * Return the library map that was populated by visiting the AST structure parsed from the
   * contents of the libraries file.
   * @return the library map describing the contents of the SDK
   */
  LibraryMap get librariesMap => _librariesMap;
  Object visitMapLiteralEntry(MapLiteralEntry node) {
    String libraryName = null;
    Expression key2 = node.key;
    if (key2 is SimpleStringLiteral) {
      libraryName = "${_LIBRARY_PREFIX}${((key2 as SimpleStringLiteral)).value}";
    }
    Expression value2 = node.value;
    if (value2 is InstanceCreationExpression) {
      SdkLibraryImpl library = new SdkLibraryImpl(libraryName);
      List<Expression> arguments2 = ((value2 as InstanceCreationExpression)).argumentList.arguments;
      for (Expression argument in arguments2) {
        if (argument is SimpleStringLiteral) {
          library.path = ((argument as SimpleStringLiteral)).value;
        } else if (argument is NamedExpression) {
          String name2 = ((argument as NamedExpression)).name.label.name;
          Expression expression2 = ((argument as NamedExpression)).expression;
          if (name2 == _CATEGORY) {
            library.category = ((expression2 as SimpleStringLiteral)).value;
          } else if (name2 == _IMPLEMENTATION) {
            library.implementation = ((expression2 as BooleanLiteral)).value;
          } else if (name2 == _DOCUMENTED) {
            library.documented = ((expression2 as BooleanLiteral)).value;
          } else if (name2 == _PLATFORMS) {
            if (expression2 is SimpleIdentifier) {
              String identifier = ((expression2 as SimpleIdentifier)).name;
              if (identifier == _VM_PLATFORM) {
                library.setVmLibrary();
              } else {
                library.setDart2JsLibrary();
              }
            }
          }
        }
      }
      _librariesMap.setLibrary(libraryName, library);
    }
    return null;
  }
}
class AnalysisErrorListener_10 implements AnalysisErrorListener {
  List<bool> foundError;
  AnalysisErrorListener_10(this.foundError);
  void onError(AnalysisError error) {
    foundError[0] = true;
  }
}