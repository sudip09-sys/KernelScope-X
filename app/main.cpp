#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include "core/MonitorController.h"
#include "models/ProcessModel.h"
#include "models/ProcessFilterModel.h"
#include "oslab/SchedulingSimulator.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("KernelScope X");
    QGuiApplication::setOrganizationName("KernelScope X");
    QGuiApplication::setApplicationVersion("0.2.0");
    QQuickStyle::setStyle("Fusion");

    ProcessModel processModel;
    ProcessFilterModel processProxy;
    processProxy.setSourceModel(&processModel);
    ProcessFilterModel overviewProxy;
    overviewProxy.setSourceModel(&processModel);
    MonitorController monitor(&processModel);
    SchedulingSimulator scheduler;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("processModel", &processModel);
    engine.rootContext()->setContextProperty("processProxy", &processProxy);
    engine.rootContext()->setContextProperty("overviewProxy", &overviewProxy);
    engine.rootContext()->setContextProperty("monitor", &monitor);
    engine.rootContext()->setContextProperty("scheduler", &scheduler);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("KernelScopeX", "Main");
    return app.exec();
}
