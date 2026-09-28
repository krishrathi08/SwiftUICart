# Contributing to SwiftCart

First off, thank you for considering contributing to SwiftCart! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Environment details** (iOS version, Xcode version, device)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide step-by-step description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **Include screenshots or mockups** if applicable

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Follow the existing code style**
   - Use SwiftUI best practices
   - Follow MVVM architecture
   - Add comments for complex logic
   - Use meaningful variable names

3. **Test your changes**
   - Ensure the app builds without errors
   - Test on multiple iOS versions if possible
   - Verify UI on different screen sizes

4. **Update documentation**
   - Update README.md if needed
   - Add inline code documentation
   - Update CHANGELOG.md

5. **Commit with clear messages**
   ```
   feat: Add product wishlist feature
   fix: Resolve cart total calculation bug
   docs: Update API integration guide
   style: Format code in ProductCard
   refactor: Extract reusable components
   test: Add unit tests for CartManager
   ```

## Code Style Guidelines

### Swift Style
- Use Swift naming conventions
- Prefer `let` over `var` when possible
- Use trailing closures
- Avoid force unwrapping (`!`)
- Use guard statements for early returns

### SwiftUI Best Practices
- Keep views small and focused
- Extract reusable components
- Use `@State`, `@Binding`, `@ObservableObject` appropriately
- Leverage view modifiers
- Use PreviewProvider for all views

### File Organization
```swift
// MARK: - Properties
// MARK: - Computed Properties
// MARK: - Body
// MARK: - Views
// MARK: - Methods
// MARK: - Helpers
```

## Project Structure

When adding new features:
- **Models** → Data structures
- **ViewModels** → Business logic and state
- **Views** → UI components
- **Services** → Network/API calls
- **Components** → Reusable UI elements
- **Utils** → Helper functions and extensions

## Questions?

Feel free to reach out:
- Open an issue with the `question` label
- Email: yxshdogra@gmail.com

Thank you for contributing! 🙌
