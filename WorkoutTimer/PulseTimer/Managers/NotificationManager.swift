import UserNotifications

class NotificationManager: ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let idPrefix = "pulsetimer."

    func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("NotificationManager: Permission request failed: \(error)")
            return false
        }
    }

    func scheduleAllNotifications(for config: WorkoutConfiguration, startTime: Date) {
        cancelAllWorkoutNotifications()

        var notifications: [(date: Date, title: String, body: String)] = []
        var currentTime = startTime

        for round in 1...config.rounds {
            for exercise in 1...config.exercisesPerRound {
                // Work phase start
                let workTitle = config.name(for: exercise) ?? "Work!"
                let workBody: String
                if let name = config.name(for: exercise) {
                    workBody = "\(name) — Round \(round), Exercise \(exercise) of \(config.exercisesPerRound)"
                } else {
                    workBody = "Round \(round) — Exercise \(exercise) of \(config.exercisesPerRound)"
                }
                notifications.append((date: currentTime, title: workTitle, body: workBody))
                currentTime = currentTime.addingTimeInterval(TimeInterval(config.workDuration))

                // Rest phase start
                let nextEx = exercise < config.exercisesPerRound ? exercise + 1 : 1
                let upNext = config.name(for: nextEx) ?? "Exercise \(nextEx)"
                notifications.append((
                    date: currentTime,
                    title: "Rest",
                    body: "Up next: \(upNext) — \(config.restDuration)s"
                ))
                currentTime = currentTime.addingTimeInterval(TimeInterval(config.restDuration))
            }

            // Round rest (between rounds)
            if round < config.rounds {
                notifications.append((
                    date: currentTime,
                    title: "Round Rest",
                    body: "Round \(round) complete — rest \(config.restBetweenRounds)s before Round \(round + 1)"
                ))
                currentTime = currentTime.addingTimeInterval(TimeInterval(config.restBetweenRounds))
            }
        }

        // Finished
        notifications.append((
            date: currentTime,
            title: "Workout Complete!",
            body: "Great job — all \(config.rounds) rounds done."
        ))

        for (index, notification) in notifications.enumerated() {
            scheduleNotification(
                id: "\(idPrefix)\(index)",
                title: notification.title,
                body: notification.body,
                date: notification.date
            )
        }
    }

    func cancelAllWorkoutNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(self.idPrefix) }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private func scheduleNotification(id: String, title: String, body: String, date: Date) {
        // Don't schedule notifications in the past
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error {
                print("NotificationManager: Failed to schedule \(id): \(error)")
            }
        }
    }
}
