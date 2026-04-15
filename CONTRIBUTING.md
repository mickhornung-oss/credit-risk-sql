# Contributing Guidelines

Thank you for your interest in contributing to credit-risk-sql! This document provides guidelines and instructions for contributing to this project.

## Getting Started

### Prerequisites
- PostgreSQL 12+
- SQL knowledge
- Python 3.8+ (for analysis scripts)

### Local Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/credit-risk-sql.git`
3. Navigate to the project: `cd credit-risk-sql`
4. Set up your PostgreSQL database with the schema from `sql/schema.sql`
5. Load sample data if provided

## Development Workflow

### Creating a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### Code Guidelines
- Write clear, well-commented SQL queries
- Follow [SQL Style Guide](https://www.sqlstyle.guide/) conventions
- Name queries descriptively: `analysis_customer_segments.sql`
- Include query documentation headers

### Query Best Practices
- Add explanatory comments
- Use CTEs for readability
- Include example outputs
- Test on sample data before committing

## Submitting Changes

### Commit Messages
- Use clear, descriptive commit messages
- Format: `type: brief description`
- Examples: `feat: add risk scoring query`, `refactor: optimize customer join`, `docs: add query examples`

### Pull Request Process
1. Push your changes to your fork
2. Open a Pull Request with:
   - Clear title describing the SQL improvement
   - Explanation of the business logic
   - Example query results
   - Performance metrics if applicable

3. Wait for review and address feedback

## Areas for Contribution

### Queries
- New risk assessment metrics
- Performance optimization
- Additional business logic

### Analysis
- Dashboard queries
- Reporting improvements
- Data validation checks

### Documentation
- Query explanations
- Use case examples
- Best practices

## Questions?

Feel free to:
- Open an Issue for feature requests or bugs
- Ask questions in Discussions
- Email the maintainer: [mick.hornung@googlemail.com](mailto:mick.hornung@googlemail.com)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Happy Contributing!** 🚀
