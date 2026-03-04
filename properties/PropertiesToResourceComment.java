
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class PropertiesToResourceComment {

    private static final Path BASE_DIR = Paths.get("C:\\filter_include");
    private static final Path INPUT_DIR = BASE_DIR.resolve("input");
    private static final Path OUTPUT_DIR = BASE_DIR.resolve("output");

    public static void main(String[] args) {
        try {
            ensureDirectories();

            List<Path> propertyFiles = listPropertiesFiles(INPUT_DIR);
            if (propertyFiles.isEmpty()) {
                System.out.println("No .properties files found in: " + INPUT_DIR);
                return;
            }

            for (Path inFile : propertyFiles) {
                Path outFile = OUTPUT_DIR.resolve(inFile.getFileName().toString());
                transformFile(inFile, outFile);
                System.out.println("Processed: " + inFile.getFileName() + " -> " + outFile);
            }

            System.out.println("Done.");
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void ensureDirectories() throws IOException {
        if (!Files.exists(INPUT_DIR)) {
            throw new IOException("Input directory not found: " + INPUT_DIR);
        }
        Files.createDirectories(OUTPUT_DIR);
    }

    private static List<Path> listPropertiesFiles(Path dir) throws IOException {
        try (Stream<Path> stream = Files.list(dir)) {
            return stream
                    .filter(Files::isRegularFile)
                    .filter(p -> p.getFileName().toString().toLowerCase().endsWith(".properties"))
                    .collect(Collectors.toList());
        }
    }

    private static void transformFile(Path inputFile, Path outputFile) throws IOException {
        try (BufferedReader reader = Files.newBufferedReader(inputFile, StandardCharsets.UTF_8);
             BufferedWriter writer = Files.newBufferedWriter(
                     outputFile,
                     StandardCharsets.UTF_8,
                     StandardOpenOption.CREATE,
                     StandardOpenOption.TRUNCATE_EXISTING
             )) {

            String line;
            while ((line = reader.readLine()) != null) {
                String transformed = transformLine(line);
                writer.write(transformed);
                writer.newLine();
            }
        }
    }

    private static String transformLine(String line) {
        String original = line;

        if (original.trim().isEmpty()) {
            return original;
        }
        String trimmed = original.trim();
        if (trimmed.startsWith("#") || trimmed.startsWith("!")) {
            return original;
        }

        int eq = original.indexOf('=');
        int colon = original.indexOf(':');
        int sepIndex;

        if (eq == -1 && colon == -1) {
            return original;
        } else if (eq == -1) {
            sepIndex = colon;
        } else if (colon == -1) {
            sepIndex = eq;
        } else {
            sepIndex = Math.min(eq, colon);
        }

        String keyPart = original.substring(0, sepIndex).trim();
        String valuePart = original.substring(sepIndex + 1).trim();

        if (keyPart.isEmpty()) {
            return original;
        }

        return "$R{" + keyPart + "}/*" + valuePart + "*/";
    }
}