<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

<p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
<p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
<a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
<a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
<a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>

## Description

Satoshi Hub Backend is a modular NestJS application for blockchain transaction processing, payload execution, and job queue management.  
It is built with TypeScript and Prisma ORM.

---

## Project setup

```bash
pnpm install
```

## Compile and run the project

```bash
# development
pnpm run start

# watch mode
pnpm run start:dev

# production mode
pnpm run start:prod
```

---

## Running Tests

To run all unit tests with coverage and open handle detection:

```bash
pnpm exec jest --coverage --detectOpenHandles
```

Test coverage reports are generated in the `coverage/` directory.

### Unit testing and mocking

When writing unit tests for services or processors that depend on other modules (for example, `PrismaService`, `BlockchainService`, `PayloadService`), you should mock those dependencies to keep your tests isolated.

**Example: How to mock services in a NestJS unit test**

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { MyService } from './my.service';
import { DependencyService } from './dependency.service';

class MockDependencyService {
  doSomething() {
    return 'mocked value';
  }
}

describe('MyService', () => {
  let service: MyService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MyService,
        { provide: DependencyService, useClass: MockDependencyService },
      ],
    }).compile();

    service = module.get<MyService>(MyService);
  });

  it('should work with the mocked dependency', () => {
    expect(service.callDependency()).toBe('mocked value');
  });
});
```

**Tips for effective mocking:**
- Replace dependencies with mock classes using `{ provide: DependencyService, useClass: MockDependencyService }`.
- Only mock the methods required for your test scenario.
- For dynamic or async behavior, use Jest’s `jest.fn()` for stubbing and spying.

---

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
pnpm install -g @nestjs/mau
mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

---

## Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [Discord channel](https://discord.gg/G7Qnnhy)
- [Official video courses](https://courses.nestjs.com/)
- [NestJS Mau AWS deployment platform](https://mau.nestjs.com)
- [NestJS Devtools](https://devtools.nestjs.com)
- [Enterprise support](https://enterprise.nestjs.com)
- [X (Twitter)](https://x.com/nestframework)
- [LinkedIn](https://linkedin.com/company/nestjs)
- [Jobs board](https://jobs.nestjs.com)

---

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

---

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

---

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).