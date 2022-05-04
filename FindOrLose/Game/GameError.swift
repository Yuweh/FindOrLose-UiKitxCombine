//
//  GameError.swift
//  FindOrLose
//
//  Created by Jay Bergonia on 5/5/22.
//

import Foundation

enum GameError: Error {
  case statusCode
  case decoding
  case invalidImage
  case invalidURL
  case other(Error)
  
  static func map(_ error: Error) -> GameError {
    return (error as? GameError) ?? .other(error)
  }
}
