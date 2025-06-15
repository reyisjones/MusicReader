import Foundation
import Compression

/// Utility class for handling ZIP archive operations
/// MuseScore files (.mscz) are ZIP archives containing MusicXML and other resources
public class ZipArchive {
    
    /// Extract contents of a ZIP archive to a temporary directory
    /// - Parameter zipURL: URL of the ZIP file to extract
    /// - Returns: URL of the temporary directory containing extracted files
    /// - Throws: ZipError if extraction fails
    static func extractArchive(at zipURL: URL) throws -> URL {
        // Create temporary directory
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(at: tempDir, 
                                              withIntermediateDirectories: true)
        
        // Read the ZIP file data
        let zipData = try Data(contentsOf: zipURL)
        
        // For this simplified implementation, we'll focus on extracting the main .mscx file
        // In a production app, you would use a proper ZIP library like ZIPFoundation
        // or implement full ZIP parsing
        
        try extractMSCZContents(zipData: zipData, to: tempDir)
        
        return tempDir
    }
    
    /// Extract MSCZ (MuseScore ZIP) contents
    /// This is a simplified implementation that looks for the main .mscx file
    private static func extractMSCZContents(zipData: Data, to destinationURL: URL) throws {
        // MuseScore files typically contain:
        // - A .mscx file (the main score in MusicXML format)
        // - META-INF/container.xml (metadata)
        // - Thumbnails and other resources
        
        // For this demo, we'll create a mock .mscx file
        // In a real implementation, you would parse the ZIP structure
        let mockMusicXML = createMockMusicXML()
        let mscxURL = destinationURL.appendingPathComponent("score.mscx")
        
        try mockMusicXML.data(using: .utf8)?.write(to: mscxURL)
        
        // Also create a basic container.xml for completeness
        let containerXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <container>
            <rootfiles>
                <rootfile full-path="score.mscx"/>
            </rootfiles>
        </container>
        """
        
        let metaInfDir = destinationURL.appendingPathComponent("META-INF")
        try FileManager.default.createDirectory(at: metaInfDir, 
                                              withIntermediateDirectories: true)
        let containerURL = metaInfDir.appendingPathComponent("container.xml")
        try containerXML.data(using: .utf8)?.write(to: containerURL)
    }
    
    /// Create a mock MusicXML file for demonstration
    /// In a real app, this would be extracted from the actual ZIP file
    private static func createMockMusicXML() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
        <score-partwise version="3.1">
          <work>
            <work-title>Sample Score</work-title>
          </work>
          <identification>
            <creator type="composer">Demo Composer</creator>
            <encoding>
              <software>MusicReader Demo</software>
              <encoding-date>\(ISO8601DateFormatter().string(from: Date()))</encoding-date>
            </encoding>
          </identification>
          <defaults>
            <scaling>
              <millimeters>7.2319</millimeters>
              <tenths>40</tenths>
            </scaling>
          </defaults>
          <part-list>
            <score-part id="P1">
              <part-name>Piano</part-name>
              <score-instrument id="P1-I1">
                <instrument-name>Piano</instrument-name>
              </score-instrument>
              <midi-device id="P1-I1" port="1"/>
              <midi-instrument id="P1-I1">
                <midi-channel>1</midi-channel>
                <midi-program>1</midi-program>
                <volume>78.7402</volume>
                <pan>0</pan>
              </midi-instrument>
            </score-part>
          </part-list>
          <part id="P1">
            <measure number="1">
              <attributes>
                <divisions>1</divisions>
                <key>
                  <fifths>0</fifths>
                </key>
                <time>
                  <beats>4</beats>
                  <beat-type>4</beat-type>
                </time>
                <clef>
                  <sign>G</sign>
                  <line>2</line>
                </clef>
              </attributes>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>D</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>E</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>F</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
            </measure>
            <measure number="2">
              <note>
                <pitch>
                  <step>G</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>A</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>B</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>5</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
    }
    
    /// Clean up temporary directory
    /// - Parameter tempURL: URL of temporary directory to remove
    static func cleanupTemporaryDirectory(at tempURL: URL) {
        try? FileManager.default.removeItem(at: tempURL)
    }
}

/// Errors that can occur during ZIP operations
enum ZipError: Error, LocalizedError {
    case invalidArchive
    case extractionFailed(String)
    case fileNotFound(String)
    case unsupportedFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidArchive:
            return "Invalid or corrupted archive file"
        case .extractionFailed(let message):
            return "Failed to extract archive: \(message)"
        case .fileNotFound(let filename):
            return "File not found in archive: \(filename)"
        case .unsupportedFormat:
            return "Unsupported archive format"
        }
    }
}
