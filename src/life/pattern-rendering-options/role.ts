import { Decoder, literal, Functor } from "io-ts/Decoder";

export enum Role {
  Pattern, // default
  InteractionPrompt,
}

export const roleDecoder: Decoder<unknown, Role> = Functor.map(
  literal("Pattern", "InteractionPrompt"),
  (value): Role => {
    switch (value) {
      case "Pattern":
        return Role.Pattern;
      case "InteractionPrompt":
        return Role.InteractionPrompt;
    }
  }
);
