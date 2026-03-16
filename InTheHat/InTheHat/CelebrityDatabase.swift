import Foundation

// MARK: - Celebrity Database

/// A session-aware name pool. Call `reset()` at the start of each new game's
/// name-entry phase so suggestions don't repeat across games.
final class CelebrityDatabase {

    static let shared = CelebrityDatabase()
    private var usedInSession: Set<String> = []

    // MARK: - Public API

    /// Returns `count` unique names not already used this session.
    /// Already-typed names can be excluded via the `excluding` parameter.
    func getRandomNames(count: Int, excluding extra: Set<String> = []) -> [String] {
        var excluded = usedInSession.union(extra)
        var results: [String] = []
        let available = Self.allNames.filter { !excluded.contains($0) }.shuffled()
        for name in available {
            guard results.count < count else { break }
            results.append(name)
            excluded.insert(name)
        }
        results.forEach { usedInSession.insert($0) }
        return results
    }

    /// Clears the used-name memory so suggestions start fresh.
    func reset() {
        usedInSession.removeAll()
    }

    // MARK: - Name Pool (200+ entries)

    static let allNames: [String] = [

        // ── Pop Culture & Music ──────────────────────────────────────────
        "Taylor Swift",
        "Beyoncé",
        "Lady Gaga",
        "Madonna",
        "Michael Jackson",
        "Elvis Presley",
        "Adele",
        "Rihanna",
        "Ed Sheeran",
        "Eminem",
        "Drake",
        "Jay-Z",
        "Kanye West",
        "Harry Styles",
        "Billie Eilish",
        "Ariana Grande",
        "Katy Perry",
        "Bruno Mars",
        "Justin Timberlake",
        "Justin Bieber",
        "Dua Lipa",
        "The Weeknd",
        "Post Malone",
        "Freddie Mercury",
        "David Bowie",
        "Bob Dylan",
        "John Lennon",
        "Paul McCartney",
        "Mick Jagger",
        "Jimi Hendrix",
        "Frank Sinatra",
        "Ella Fitzgerald",
        "Whitney Houston",
        "Mariah Carey",
        "Elton John",
        "Prince",
        "Dolly Parton",
        "Johnny Cash",
        "Kurt Cobain",
        "Amy Winehouse",

        // ── Film & Television ────────────────────────────────────────────
        "Tom Hanks",
        "Meryl Streep",
        "Brad Pitt",
        "Angelina Jolie",
        "Leonardo DiCaprio",
        "Johnny Depp",
        "Scarlett Johansson",
        "Jennifer Aniston",
        "George Clooney",
        "Julia Roberts",
        "Will Smith",
        "Denzel Washington",
        "Samuel L. Jackson",
        "Morgan Freeman",
        "Cate Blanchett",
        "Nicole Kidman",
        "Hugh Jackman",
        "Ryan Reynolds",
        "Robert Downey Jr.",
        "Dwayne Johnson",
        "Keanu Reeves",
        "Arnold Schwarzenegger",
        "Sylvester Stallone",
        "Jim Carrey",
        "Robin Williams",
        "Eddie Murphy",
        "Marilyn Monroe",
        "Audrey Hepburn",
        "Charlie Chaplin",
        "Marlon Brando",
        "James Dean",
        "Cary Grant",
        "Humphrey Bogart",
        "Clint Eastwood",
        "Al Pacino",
        "Robert De Niro",
        "Jack Nicholson",
        "Tom Cruise",
        "Oprah Winfrey",
        "Ellen DeGeneres",
        "Jerry Seinfeld",
        "Dave Chappelle",
        "Kevin Hart",
        "Chris Rock",
        "Tina Fey",
        "Amy Schumer",

        // ── History ──────────────────────────────────────────────────────
        "Napoleon Bonaparte",
        "Julius Caesar",
        "Cleopatra",
        "Alexander the Great",
        "Joan of Arc",
        "Abraham Lincoln",
        "George Washington",
        "Thomas Jefferson",
        "Benjamin Franklin",
        "Winston Churchill",
        "Mahatma Gandhi",
        "Martin Luther King Jr.",
        "Nelson Mandela",
        "Queen Victoria",
        "Henry VIII",
        "Marie Curie",
        "Albert Einstein",
        "Isaac Newton",
        "Galileo Galilei",
        "Charles Darwin",
        "Nikola Tesla",
        "Thomas Edison",
        "Sigmund Freud",
        "Karl Marx",
        "Vladimir Lenin",
        "Franklin D. Roosevelt",
        "John F. Kennedy",
        "Margaret Thatcher",
        "Charles de Gaulle",
        "Genghis Khan",
        "William Shakespeare",
        "Leonardo da Vinci",
        "Michelangelo",
        "Wolfgang Amadeus Mozart",
        "Ludwig van Beethoven",
        "Florence Nightingale",
        "Rosa Parks",
        "Harriet Tubman",
        "Frederick Douglass",
        "Che Guevara",
        "Marco Polo",
        "Christopher Columbus",
        "Neil Armstrong",
        "Amelia Earhart",
        "Theodore Roosevelt",
        "Barack Obama",
        "Queen Elizabeth II",
        "Mao Zedong",
        "Confucius",
        "Socrates",
        "Aristotle",
        "Archimedes",
        "Copernicus",
        "Ada Lovelace",
        "Alan Turing",
        "Yuri Gagarin",
        "Buzz Aldrin",
        "Anne Frank",
        "Abraham Lincoln",
        "Catherine the Great",
        "Peter the Great",
        "Ivan the Terrible",
        "William the Conqueror",

        // ── Sports ───────────────────────────────────────────────────────
        "Muhammad Ali",
        "Michael Jordan",
        "LeBron James",
        "Kobe Bryant",
        "Serena Williams",
        "Roger Federer",
        "Rafael Nadal",
        "Novak Djokovic",
        "Usain Bolt",
        "Michael Phelps",
        "Lionel Messi",
        "Cristiano Ronaldo",
        "Pelé",
        "Diego Maradona",
        "Wayne Gretzky",
        "Tiger Woods",
        "Jack Nicklaus",
        "Carl Lewis",
        "Jesse Owens",
        "Babe Ruth",
        "Mike Tyson",
        "Floyd Mayweather",
        "Simone Biles",
        "Venus Williams",
        "Neymar Jr.",
        "Kylian Mbappé",
        "Tom Brady",
        "Peyton Manning",
        "Michael Schumacher",
        "Lewis Hamilton",
        "Ayrton Senna",
        "Zinedine Zidane",
        "David Beckham",
        "Ronaldinho",
        "Magic Johnson",
        "Larry Bird",
        "Shaquille O'Neal",
        "Derek Jeter",
        "Mia Hamm",
        "Steffi Graf",
        "Lance Armstrong",

        // ── Science & Technology ─────────────────────────────────────────
        "Stephen Hawking",
        "Elon Musk",
        "Bill Gates",
        "Steve Jobs",
        "Mark Zuckerberg",
        "Jeff Bezos",
        "Neil deGrasse Tyson",
        "Richard Feynman",
        "Charles Babbage",
        "Tim Berners-Lee",
        "Nikola Tesla",
        "Alexander Graham Bell",
        "Louis Pasteur",
        "Carl Sagan",
        "Jane Goodall",
        "David Attenborough",

        // ── Literature & Art ─────────────────────────────────────────────
        "Jane Austen",
        "Charles Dickens",
        "Mark Twain",
        "Ernest Hemingway",
        "F. Scott Fitzgerald",
        "Leo Tolstoy",
        "Victor Hugo",
        "J.K. Rowling",
        "Stephen King",
        "Agatha Christie",
        "Arthur Conan Doyle",
        "Edgar Allan Poe",
        "Pablo Picasso",
        "Salvador Dalí",
        "Vincent van Gogh",
        "Claude Monet",
        "Andy Warhol",
        "Frida Kahlo",
        "Walt Disney",

        // ── Film Makers ──────────────────────────────────────────────────
        "Alfred Hitchcock",
        "Steven Spielberg",
        "Martin Scorsese",
        "Stanley Kubrick",
        "Quentin Tarantino",
        "Christopher Nolan",
        "Ridley Scott",
        "Tim Burton",

        // ── TV & Media Personalities ─────────────────────────────────────
        "Conan O'Brien",
        "David Letterman",
        "Jay Leno",
        "Jimmy Fallon",
        "Jimmy Kimmel",
        "James Corden",
        "Graham Norton",
        "Piers Morgan",
        "Gordon Ramsay",
        "Simon Cowell",

        // ── Politics & World Leaders ─────────────────────────────────────
        "Joe Biden",
        "Donald Trump",
        "Angela Merkel",
        "Emmanuel Macron",
        "Justin Trudeau",
        "Boris Johnson",
        "Vladimir Putin",
        "Xi Jinping",
        "Jacinda Ardern",
        "Tony Blair",
        "Bill Clinton",
        "George W. Bush",
        "Mikhail Gorbachev",
        "Fidel Castro",
        "Desmond Tutu",
        "Aung San Suu Kyi",

        // ── Royals & Nobility ────────────────────────────────────────────
        "Prince Harry",
        "Meghan Markle",
        "Prince William",
        "Princess Diana",
        "King Charles III",
        "Prince Philip",

        // ── Business & Entrepreneurs ────────────────────────────────────
        "Richard Branson",
        "Warren Buffett",
        "Oprah Winfrey",
        "Jack Ma",
        "Larry Page",
        "Sergey Brin"

    ].removingDuplicates()
}

// MARK: - Array helper

private extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
