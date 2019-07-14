
/*
 Copyright (C) 2018 Quaternion Risk Management Ltd
 All rights reserved.
*/

#ifndef orea_i
#define orea_i

%{
#include <boost/shared_ptr.hpp>
#include <boost/assert.hpp>
#include <boost/current_function.hpp>

#include <exception>
#include <sstream>
#include <string>
#include <map>
#include <vector>

#include <ql/errors.hpp>

#include <orea/orea.hpp>
#ifdef BOOST_MSVC
#include <orea/auto_link.hpp>
#define BOOST_LIB_NAME boost_regex
#include <boost/config/auto_link.hpp>
#define BOOST_LIB_NAME boost_serialization
#include <boost/config/auto_link.hpp>
#define BOOST_LIB_NAME boost_date_time
#include <boost/config/auto_link.hpp>
#define BOOST_LIB_NAME boost_filesystem
#include <boost/config/auto_link.hpp>
#define BOOST_LIB_NAME boost_system
#include <boost/config/auto_link.hpp>
#endif

%}

%include orea_app.i


namespace ore {
namespace analytics {

//! Stress Test Analysis
/*!
  This class wraps functionality to perform a stress testing analysis for a given portfolio.
  It comprises
  - building the "simulation" market to which sensitivity scenarios are applied
  - building the portfolio linked to this simulation market
  - generating sensitivity scenarios
  - running the scenario "engine" to apply these and compute the NPV impacts of all required shifts
  - fill result structures that can be queried
  - write stress test report to a file

  \ingroup simulation
*/
class StressTest {
public:
    //! Constructor
    StressTest(const boost::shared_ptr<ore::data::Portfolio>& portfolio, boost::shared_ptr<ore::data::Market>& market,
               const string& marketConfiguration, const boost::shared_ptr<ore::data::EngineData>& engineData,
               boost::shared_ptr<ore::analytics::ScenarioSimMarketParameters>& simMarketData,
               const boost::shared_ptr<ore::analytics::StressTestScenarioData>& stressData, const Conventions& conventions,
               const ore::data::CurveConfigurations& curveConfigs = ore::data::CurveConfigurations(),
               const ore::data::TodaysMarketParameters& todaysMarketParams = ore::data::TodaysMarketParameters(),
               boost::shared_ptr<ore::analytics::ScenarioFactory> scenarioFactory = {}, bool continueOnError = false);

    //! Return set of trades analysed
    const std::set<std::string>& trades() { return trades_; }

    //! Return unique set of factors shifted
    const std::set<std::string>& stressTests() { return labels_; }

    //! Return base NPV by trade, before shift
    const std::map<std::string, Real>& baseNPV() { return baseNPV_; }

    //! Return shifted NPVs by trade and scenario
    const std::map<std::pair<std::string, std::string>, Real>& shiftedNPV() { return shiftedNPV_; }

    //! Write NPV by trade/scenario to a file (base and shifted NPVs, delta)
    void writeReport(const boost::shared_ptr<ore::data::Report>& report, Real outputThreshold = 0.0);

private:
    // base NPV by trade
    std::map<std::string, Real> baseNPV_;
    // NPV respectively sensitivity by trade and scenario
    std::map<std::pair<string, string>, Real> shiftedNPV_, delta_;
    // scenario labels
    std::set<std::string> labels_, trades_;
};
} // namespace analytics
} // namespace ore



#endif
