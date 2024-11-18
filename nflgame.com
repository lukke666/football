import random
import time

class Player:
    def __init__(self, name, age=18, speed=50, shooting=50, defense=50, stamina=50):
        self.name = name
        self.age = age
        self.speed = speed
        self.shooting = shooting
        self.defense = defense
        self.stamina = stamina
        self.goals_scored = 0
        self.experience = 0
        self.team = "Free Agent"
        self.retired = False

    def train(self):
        """Simulate training to improve skills."""
        print(f"\n{self.name} is training...")
        improvement = random.randint(1, 5)
        stat_choice = random.choice(['speed', 'shooting', 'defense', 'stamina'])
        current_value = getattr(self, stat_choice)
        new_value = current_value + improvement
        setattr(self, stat_choice, new_value)
        self.experience += 10
        print(f"{stat_choice.capitalize()} improved by {improvement}! Current {stat_choice}: {new_value}")
        
    def play_match(self, opponent_strength):
        """Simulate playing a match."""
        print(f"\n{self.name} is playing a match...")
        performance = self.shooting * 0.5 + self.speed * 0.3 + self.stamina * 0.2
        match_outcome = performance - opponent_strength
        goals_scored = 0

        if match_outcome > random.randint(0, 100):
            goals_scored = random.randint(0, 3)  # Goals scored in the match
            self.goals_scored += goals_scored
            print(f"{self.name} scored {goals_scored} goal(s) in the match!")
        else:
            print(f"{self.name} didn't score in this match.")
        
        return goals_scored

    def get_stats(self):
        return {
            'Age': self.age,
            'Goals Scored': self.goals_scored,
            'Experience': self.experience,
            'Speed': self.speed,
            'Shooting': self.shooting,
            'Defense': self.defense,
            'Stamina': self.stamina
        }

    def age_up(self):
        """Increase the player's age and check for retirement."""
        self.age += 1
        if self.age > 35:
            self.retired = True

    def career_summary(self):
        """Show a summary of the player's career."""
        stats = self.get_stats()
        print("\n--- Career Summary ---")
        for stat, value in stats.items():
            print(f"{stat}: {value}")
        print(f"Retired: {self.retired}")
        print(f"Team: {self.team}")


class Game:
    def __init__(self):
        self.player = None
        self.season = 1
        self.opponent_strength = 60  # Starting opponent strength

    def start_game(self):
        print("Welcome to Football Career Simulator!")
        name = input("Enter your player's name: ")
        self.player = Player(name)
        print(f"\nWelcome {self.player.name} to your new football career!")
        self.main_menu()

    def main_menu(self):
        while not self.player.retired:
            print(f"\n--- Season {self.season} ---")
            print("1. View Player Stats")
            print("2. Train")
            print("3. Play Match")
            print("4. Career Summary")
            print("5. Retire (End Career)")
            choice = input("Choose an option: ")

            if choice == "1":
                self.view_player_stats()
            elif choice == "2":
                self.train()
            elif choice == "3":
                self.play_match()
            elif choice == "4":
                self.career_summary()
            elif choice == "5":
                self.retire_player()
                break
            else:
                print("Invalid choice. Try again.")
        
        print("\nGame Over! Thanks for playing!")

    def view_player_stats(self):
        stats = self.player.get_stats()
        print("\n--- Player Stats ---")
        for stat, value in stats.items():
            print(f"{stat}: {value}")
        
    def train(self):
        self.player.train()
        self.next_season()

    def play_match(self):
        print(f"\nYou are facing an opponent with strength {self.opponent_strength}")
        goals = self.player.play_match(self.opponent_strength)
        print(f"\n{self.player.name} scored {goals} goal(s) this match.")
        self.opponent_strength += random.randint(-5, 5)  # Opponent strength may fluctuate a little
        self.next_season()

    def career_summary(self):
        self.player.career_summary()
        
    def retire_player(self):
        print(f"{self.player.name} has decided to retire!")
        self.player.retired = True

    def next_season(self):
        self.player.age_up()
        if not self.player.retired:
            self.season += 1
            print(f"\n--- Season {self.season} ---")
            time.sleep(1)  # Pause for effect, like a real game
        else:
            print(f"{self.player.name} is too old to play.")
            self.main_menu()


if __name__ == "__main__":
    game = Game()
    game.start_game()
