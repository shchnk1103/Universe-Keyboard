public protocol CandidateProvider {
    func candidates(for composition: String) -> [String]
}
