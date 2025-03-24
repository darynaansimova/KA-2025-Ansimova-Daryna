import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class Project {
    public static void main(String[] args) throws IOException {
        if (args.length < 1) {
            System.out.println("NO ARGUMENTS PRESENT");
            return;ja
        }

        String substring = args[0];
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> lines = new ArrayList<>();
        String line;

        // Read lines from stdin
        while ((line = reader.readLine()) != null && lines.size() < 100) {
            if (line.length() > 255) {
                line = line.substring(0, 255); // Limit line to 255 characters
            }
            lines.add(line);
        }

        ArrayList<Result> results = new ArrayList<>();

        // Count occurrences of substring for each line
        for (int i = 0; i < lines.size(); i++) {
            int count = countOccurrences(lines.get(i), substring);
            results.add(new Result(count, i));
        }

        // Sort results using Merge Sort
        results = mergeSort(results);

        // Print the results
        for (Result result : results) {
            System.out.println(result.count + " " + result.index);
        }
    }

    // Function to count non-overlapping occurrences of a substring
    public static int countOccurrences(String line, String substring) {
        int count = 0;
        int index = 0;

        while ((index = line.indexOf(substring, index)) != -1) {
            count++;
            index += substring.length(); // Move past the current match
        }

        return count;
    }

    // Merge Sort implementation
    public static ArrayList<Result> mergeSort(ArrayList<Result> list) {
        if (list.size() <= 1) {
            return list;
        }

        int mid = list.size() / 2;
        ArrayList<Result> left = new ArrayList<>(list.subList(0, mid));
        ArrayList<Result> right = new ArrayList<>(list.subList(mid, list.size()));

        left = mergeSort(left);
        right = mergeSort(right);

        return merge(left, right);
    }

    public static ArrayList<Result> merge(ArrayList<Result> left, ArrayList<Result> right) {
        ArrayList<Result> merged = new ArrayList<>();
        int i = 0, j = 0;

        while (i < left.size() && j < right.size()) {
            if (left.get(i).count <= right.get(j).count) {
                merged.add(left.get(i));
                i++;
            } else {
                merged.add(right.get(j));
                j++;
            }
        }

        while (i < left.size()) {
            merged.add(left.get(i));
            i++;
        }

        while (j < right.size()) {
            merged.add(right.get(j));
            j++;
        }

        return merged;
    }

    // Helper class to store results
    static class Result {
        int count;
        int index;

        Result(int count, int index) {
            this.count = count;
            this.index = index;
        }
    }
}
