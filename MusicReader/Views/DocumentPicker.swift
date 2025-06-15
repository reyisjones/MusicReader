import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// SwiftUI wrapper for UIDocumentPickerViewController
struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onDocumentSelected: (URL) -> Void
    let onCancel: () -> Void
    
    init(allowedContentTypes: [UTType] = [
        UTType(filenameExtension: "mscz") ?? UTType.data,
        UTType(filenameExtension: "musicxml") ?? UTType.xml,
        UTType.xml,
        UTType(filenameExtension: "mid") ?? UTType.data,
        UTType(filenameExtension: "midi") ?? UTType.data
    ], onDocumentSelected: @escaping (URL) -> Void, onCancel: @escaping () -> Void = {}) {
        self.allowedContentTypes = allowedContentTypes
        self.onDocumentSelected = onDocumentSelected
        self.onCancel = onCancel
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }
            
            // Copy file to app's documents directory for persistent access
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            do {
                // Remove existing file if it exists
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                // Copy the file
                try fileManager.copyItem(at: url, to: destinationURL)
                
                // Call the completion handler with the local copy
                parent.onDocumentSelected(destinationURL)
            } catch {
                print("Failed to copy file: \(error)")
                // Fall back to using the original URL
                parent.onDocumentSelected(url)
            }
            
            // Stop accessing security-scoped resource
            url.stopAccessingSecurityScopedResource()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel()
        }
    }
}

/// Drag and drop view for iPad
struct DropZone: View {
    let onFileDrop: (URL) -> Void
    @State private var isTargeted = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isTargeted ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTargeted ? Color.blue : Color.gray, lineWidth: 2)
                    .opacity(isTargeted ? 1.0 : 0.5)
            )
            .frame(height: 150)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(isTargeted ? .blue : .gray)
                    
                    Text(isTargeted ? "Drop your music file here" : "Drag & drop music files here")
                        .font(.headline)
                        .foregroundColor(isTargeted ? .blue : .gray)
                    
                    Text("Supports .mscz, .musicxml, .mid files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                guard let provider = providers.first else { return false }
                
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                    if let data = data as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            onFileDrop(url)
                        }
                    }
                }
                
                return true
            }
    }
}

/// File import button with icon
struct FileImportButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "folder.badge.plus")
                Text("Import Music File")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}

/// Preview for document picker components
#Preview {
    VStack(spacing: 20) {
        DropZone { url in
            print("File dropped: \(url)")
        }
        
        FileImportButton {
            print("Import button tapped")
        }
    }
    .padding()
}
