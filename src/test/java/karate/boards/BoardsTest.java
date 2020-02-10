package karate.boards;

import com.intuit.karate.KarateOptions;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import net.masterthought.cucumber.presentation.PresentationMode;
import net.masterthought.cucumber.sorting.SortingMethod;
import org.apache.commons.io.FileUtils;
import org.apache.maven.model.Model;
import org.apache.maven.model.io.xpp3.MavenXpp3Reader;
import org.codehaus.plexus.util.xml.pull.XmlPullParserException;
import org.junit.Test;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import static org.junit.Assert.assertTrue;

@KarateOptions(features = "classpath:karate/boards")
public class BoardsTest {

    private final String project_name = "Trello API test demo - karate";

    @Test
    public void testParallel() {
        Results results = Runner.parallel(getClass(), 1, "target/surefire-reports");
        generateReport(results.getReportDir());
        assertTrue(results.getErrorMessages(), results.getFailCount() == 0);
    }

    private void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[]{"json"}, true);
        List<String> jsonPaths = new ArrayList(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));

        Configuration config = new Configuration(new File("target"), project_name);
        config.setSortingMethod(SortingMethod.NATURAL);
        config.addPresentationModes(PresentationMode.EXPAND_ALL_STEPS);
        config.setBuildNumber(getTestVersion());

        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

    private String getTestVersion() {
        MavenXpp3Reader reader = new MavenXpp3Reader();
        Model model;
        try {
            model = reader.read(new FileReader("pom.xml"));
        } catch (IOException | XmlPullParserException e) {
            System.out.println("Unable to read pom.xml file during retrieve artifact version. Cause: " + e.getLocalizedMessage());
            return "";
        }
        return model.getVersion();
    }
}
